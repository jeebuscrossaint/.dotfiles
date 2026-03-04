pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

/**
 * MangoWM (mango) compositor data service.
 * Uses mmsg -g for initial snapshot and mmsg -w to stream events.
 *
 * mmsg line format:
 *   <monitor> tag <N> <selected> <occupied> <urgent>
 *   <monitor> title <window title>
 *   <monitor> appid <app id>
 *   <monitor> layout <layout code>
 *   <monitor> kb_layout <layout name>
 *   <monitor> clients <count>
 *   <monitor> selmon <0|1>
 */
Singleton {
    id: root

    // Tag state for all monitors: { "eDP-1": { tags: [...], activeTag: 1, ... } }
    property var monitorData: ({})
    property var monitorNames: []

    // The currently selected (focused) monitor name
    property string selectedMonitor: ""

    // Convenience properties for the currently selected monitor
    readonly property var activeTags: {
        const m = root.monitorData[root.selectedMonitor];
        return m ? m.tags : _emptyTags;
    }
    readonly property int activeTagId: {
        const m = root.monitorData[root.selectedMonitor];
        return m ? m.activeTag : 1;
    }

    // Active workspace object (HyprlandData API compat)
    property var activeWorkspace: ({ id: 1, name: "1", monitor: "" })

    // Focused window on selected monitor
    property string focusedTitle: ""
    property string focusedAppId: ""
    property string currentLayout: ""
    property string keyboardLayout: ""
    property int clientCount: 0

    // Number of tags to show (MangoWM default is 9)
    readonly property int numTags: 9

    // Whether MangoWM is the active compositor
    readonly property bool available: Qt.platform.os === "linux"

    property var _emptyTags: Array.from({ length: 9 }, (_, i) => ({
        id: i + 1, selected: false, occupied: false, urgent: false
    }))

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    // Switch to a tag by number (1-9)
    function switchTag(n) {
        switchTagProc.command = ["mmsg", "-s", "-t", String(n)];
        switchTagProc.running = true;
    }

    // Switch to next/previous tag (relative)
    function switchTagRelative(delta) {
        const cur = root.activeTagId;
        const next = Math.max(1, Math.min(root.numTags, cur + delta));
        root.switchTag(next);
    }

    // Dispatch a mango internal command (like hyprctl dispatch)
    function dispatch(cmd) {
        dispatchProc.command = ["mmsg", "-d", cmd];
        dispatchProc.running = true;
    }

    // For HyprlandData API compat: get biggest window in a "workspace" (tag)
    // MangoWM doesn't expose per-tag window lists over IPC, so we fall back to
    // the ToplevelManager active toplevel.
    function biggestWindowForWorkspace(tagId) {
        return ToplevelManager.activeToplevel ?? null;
    }

    function toplevelsForWorkspace(tagId) {
        // Can't know per-tag window lists without Hyprland IPC equivalent
        // Return all toplevels as best effort
        return ToplevelManager.toplevels.values;
    }

    function clientForToplevel(toplevel) {
        if (!toplevel) return null;
        return {
            class: toplevel.appId ?? "",
            title: toplevel.title ?? "",
            workspace: { id: root.activeTagId },
        };
    }

    // -------------------------------------------------------------------------
    // Internal parsing
    // -------------------------------------------------------------------------

    // Accumulate lines before flushing to avoid partial-state renders
    property var _buf: ({})

    function _parseLine(line) {
        const trimmed = line.trim();
        if (!trimmed) return;

        // Split into at most 3 parts: monitor, key, rest
        const spaceIdx = trimmed.indexOf(" ");
        if (spaceIdx < 0) return;
        const monitor = trimmed.substring(0, spaceIdx);
        const rest = trimmed.substring(spaceIdx + 1);

        const spaceIdx2 = rest.indexOf(" ");
        const key = spaceIdx2 >= 0 ? rest.substring(0, spaceIdx2) : rest;
        const value = spaceIdx2 >= 0 ? rest.substring(spaceIdx2 + 1) : "";

        // Init monitor buffer
        if (!root._buf[monitor]) {
            root._buf[monitor] = {
                tags: Array.from({ length: 9 }, (_, i) => ({
                    id: i + 1, selected: false, occupied: false, urgent: false
                })),
                activeTag: 1,
                title: "",
                appid: "",
                layout: "",
                kbLayout: "",
                clients: 0,
                isSelected: false,
            };
        }
        const m = root._buf[monitor];

        switch (key) {
            case "tag": {
                const parts = value.split(" ");
                const tagNum = parseInt(parts[0]);
                const selected = parts[1] === "1";
                const occupied = parts[2] === "1";
                const urgent = parts[3] === "1";
                if (tagNum >= 1 && tagNum <= 9) {
                    m.tags[tagNum - 1] = { id: tagNum, selected, occupied, urgent };
                    if (selected) m.activeTag = tagNum;
                }
                break;
            }
            case "title":
                m.title = value;
                break;
            case "appid":
                m.appid = value;
                break;
            case "layout":
                m.layout = value;
                break;
            case "kb_layout":
                m.kbLayout = value;
                break;
            case "clients":
                m.clients = parseInt(value) || 0;
                break;
            case "selmon":
                m.isSelected = value === "1";
                if (m.isSelected) root.selectedMonitor = monitor;
                break;
            default:
                break;
        }

        root._buf[monitor] = m;
    }

    function _flushState() {
        const buf = root._buf;
        const names = Object.keys(buf);
        root.monitorNames = names;

        // Find selected monitor if not already set
        if (!root.selectedMonitor || !buf[root.selectedMonitor]) {
            for (const name of names) {
                if (buf[name].isSelected) {
                    root.selectedMonitor = name;
                    break;
                }
            }
            if (!root.selectedMonitor && names.length > 0) {
                root.selectedMonitor = names[0];
            }
        }

        root.monitorData = Object.assign({}, buf);

        const selMon = buf[root.selectedMonitor];
        if (selMon) {
            root.focusedTitle = selMon.title;
            root.focusedAppId = selMon.appid;
            root.currentLayout = selMon.layout;
            root.keyboardLayout = selMon.kbLayout;
            root.clientCount = selMon.clients;
            root.activeWorkspace = {
                id: selMon.activeTag,
                name: String(selMon.activeTag),
                monitor: root.selectedMonitor,
            };
        }
    }

    // -------------------------------------------------------------------------
    // Processes
    // -------------------------------------------------------------------------

    // Initial snapshot
    Process {
        id: initProc
        running: true
        command: ["mmsg", "-g"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => root._parseLine(line)
        }
        onExited: {
            root._flushState();
            watchProc.running = true;
        }
    }

    // Continuous watch (streams events as they happen)
    Process {
        id: watchProc
        running: false
        command: ["mmsg", "-w"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                root._parseLine(line);
                flushTimer.restart();
            }
        }
        onExited: {
            // Restart on unexpected exit
            restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        repeat: false
        onTriggered: {
            root._buf = ({});
            initProc.running = true;
        }
    }

    // Debounce flush: mmsg -w sends many lines at once for each state change
    Timer {
        id: flushTimer
        interval: 16
        repeat: false
        onTriggered: root._flushState()
    }

    // Tag switch
    Process {
        id: switchTagProc
        command: ["mmsg", "-s", "-t", "1"]
    }

    // Generic dispatch
    Process {
        id: dispatchProc
        command: ["mmsg", "-d", ""]
    }
}
