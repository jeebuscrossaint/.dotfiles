pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

/**
 * niri compositor data service.
 * Connects to $NIRI_SOCKET and subscribes to the event stream.
 *
 * niri IPC: write JSON request on one line, read JSON responses.
 * Event stream: send "EventStream" request, then read continuous JSON events.
 *
 * Key events used:
 *   WorkspacesChanged    -> { workspaces: [...] }
 *   WorkspaceActivated   -> { id, focused }
 *   WindowFocusChanged   -> { id } (null = no focus)
 *   WindowOpenedOrChanged -> { window: { id, workspace_id, title, app_id } }
 *   WindowClosed         -> { id }
 */
Singleton {
    id: root

    property var workspaces: []        // [{ id, name, output, active_window_id, is_active, is_focused }]
    property var windows: ({})         // { id: { id, title, app_id, workspace_id } }
    property int activeWorkspaceId: 1
    property var activeWorkspace: ({ id: 1, name: "1" })
    property string focusedTitle: ""
    property string focusedAppId: ""
    property int focusedWindowId: -1

    readonly property string socketPath: Qt.environment("NIRI_SOCKET") ?? ""
    readonly property bool available: root.socketPath !== ""

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    function switchWorkspace(id) {
        switchProc.command = [
            "sh", "-c",
            `printf '"{\\"Action\\":{\\"FocusWorkspace\\":{\\"reference\\":{\\"Id\\":${id}}}}}\n"' | socat - "$NIRI_SOCKET"`
        ];
        switchProc.running = true;
    }

    function switchWorkspaceRelative(delta) {
        // Get sorted workspace ids and step relative to current
        const sorted = root.workspaces.slice().sort((a, b) => a.id - b.id);
        const idx = sorted.findIndex(ws => ws.id === root.activeWorkspaceId);
        if (idx < 0) return;
        const nextIdx = Math.max(0, Math.min(sorted.length - 1, idx + delta));
        root.switchWorkspace(sorted[nextIdx].id);
    }

    function biggestWindowForWorkspace(wsId) {
        return ToplevelManager.activeToplevel ?? null;
    }

    // -------------------------------------------------------------------------
    // Socket connection to niri event stream
    // -------------------------------------------------------------------------

    Socket {
        id: niriSocket
        path: root.socketPath
        connected: root.available

        onConnected: {
            // Request event stream
            niriSocket.write('["EventStream"]\n');
            niriSocket.flush();
        }

        parser: SplitParser {
            splitMarker: "\n"
            onRead: line => root._handleEvent(line)
        }
    }

    function _handleEvent(line) {
        const trimmed = line.trim();
        if (!trimmed) return;
        let msg;
        try {
            msg = JSON.parse(trimmed);
        } catch(e) {
            return;
        }

        // niri events come as { "Event": { "EventName": { ... } } }
        // or as direct Ok/Err responses
        if (!msg) return;

        const eventContainer = msg["Event"] ?? msg;

        if (eventContainer["WorkspacesChanged"]) {
            root._handleWorkspacesChanged(eventContainer["WorkspacesChanged"].workspaces);
        } else if (eventContainer["WorkspaceActivated"]) {
            const ev = eventContainer["WorkspaceActivated"];
            if (ev.focused) {
                root.activeWorkspaceId = ev.id;
                const ws = root.workspaces.find(w => w.id === ev.id);
                if (ws) root.activeWorkspace = ws;
            }
        } else if (eventContainer["WindowFocusChanged"]) {
            const ev = eventContainer["WindowFocusChanged"];
            root.focusedWindowId = ev.id ?? -1;
            const win = ev.id ? root.windows[ev.id] : null;
            root.focusedTitle = win?.title ?? "";
            root.focusedAppId = win?.app_id ?? "";
        } else if (eventContainer["WindowOpenedOrChanged"]) {
            const win = eventContainer["WindowOpenedOrChanged"].window;
            if (win) {
                let updated = Object.assign({}, root.windows);
                updated[win.id] = win;
                root.windows = updated;
                if (win.id === root.focusedWindowId) {
                    root.focusedTitle = win.title ?? "";
                    root.focusedAppId = win.app_id ?? "";
                }
            }
        } else if (eventContainer["WindowClosed"]) {
            const id = eventContainer["WindowClosed"].id;
            let updated = Object.assign({}, root.windows);
            delete updated[id];
            root.windows = updated;
            if (id === root.focusedWindowId) {
                root.focusedTitle = "";
                root.focusedAppId = "";
                root.focusedWindowId = -1;
            }
        }
    }

    function _handleWorkspacesChanged(wsList) {
        if (!wsList) return;
        root.workspaces = wsList;
        const active = wsList.find(ws => ws.is_active && ws.is_focused)
            ?? wsList.find(ws => ws.is_active)
            ?? wsList[0];
        if (active) {
            root.activeWorkspaceId = active.id;
            root.activeWorkspace = active;
        }
    }

    // Process for dispatch (workspace switch etc via socat)
    Process {
        id: switchProc
        command: ["sh", "-c", ""]
    }
}
