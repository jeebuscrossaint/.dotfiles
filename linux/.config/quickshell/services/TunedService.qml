pragma Singleton

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/*
 * tuned-adm integration — no root or sudo required.
 * tuned-adm talks to the tuned daemon over D-Bus as any user.
 */
Singleton {
    id: root

    property bool available: false
    property string activeProfile: ""
    property var profiles: []       // list of strings: profile names
    property bool switching: false

    function iconForProfile(name) {
        const n = (name ?? "").toLowerCase();
        if (n.includes("battery") || n.includes("powersave") || n.includes("power-save") || n.includes("saving"))
            return "energy_savings_leaf";
        if (n.includes("performance") || n.includes("throughput") || n.includes("latency-perf") || n.includes("accelerator") || n.includes("hpc"))
            return "local_fire_department";
        if (n.includes("realtime") || n.includes("gaming"))
            return "sports_esports";
        if (n.includes("network") || n.includes("server") || n.includes("virtual") || n.includes("aws") || n.includes("openshift"))
            return "dns";
        if (n.includes("desktop"))
            return "computer";
        return "airwave";
    }

    function setProfile(name) {
        if (switching || name === activeProfile) return;
        switching = true;
        switchProc.command = ["tuned-adm", "profile", name];
        switchProc.running = true;
    }

    function reload() {
        if (available) {
            activeProc.running = true;
        }
    }

    Component.onCompleted: {
        checkProc.running = true;
    }

    // ── Availability check ────────────────────────────────────────────────
    Process {
        id: checkProc
        command: ["sh", "-c", "command -v tuned-adm >/dev/null 2>&1 && echo ok"]
        stdout: SplitParser {
            onRead: line => {
                if (line.trim() === "ok") {
                    root.available = true;
                    activeProc.running = true;
                    listProc.running = true;
                }
            }
        }
    }

    // ── Active profile ────────────────────────────────────────────────────
    Process {
        id: activeProc
        command: ["tuned-adm", "active"]
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/Current active profile:\s*(.+)/);
                if (m) root.activeProfile = m[1].trim();
            }
        }
    }

    // ── Profile list ──────────────────────────────────────────────────────
    property var _buf: []
    Process {
        id: listProc
        command: ["tuned-adm", "list"]
        onRunningChanged: if (running) root._buf = []
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/^- (\S+)/);
                if (m) root._buf = root._buf.concat([m[1]]);
            }
        }
        onExited: root.profiles = root._buf
    }

    // ── Profile switch ────────────────────────────────────────────────────
    Process {
        id: switchProc
        onExited: (exitCode) => {
            root.switching = false;
            if (exitCode === 0) activeProc.running = true;
        }
    }

    // ── Refresh active profile every 30 s (tracks external changes) ───────
    Timer {
        interval: 30000
        repeat: true
        running: root.available
        onTriggered: activeProc.running = true
    }
}
