pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/**
 * Detects and exposes the active Wayland compositor.
 * Detection is based on environment variables set by each compositor.
 *
 * Usage:
 *   if (Compositor.isHyprland) { ... }
 *   if (Compositor.isMango)    { ... }
 *   if (Compositor.isNiri)     { ... }
 */
Singleton {
    id: root

    // Environment variable values — populated asynchronously at startup via shell.
    // Defaults to empty, so isMango defaults to true (correct for MangoWM).
    property string _hyprlandSig: ""
    property string _niriSocket: ""

    // Probe HYPRLAND_INSTANCE_SIGNATURE
    Process {
        id: hyprProbe
        command: ["sh", "-c", "echo \"$HYPRLAND_INSTANCE_SIGNATURE\""]
        running: true
        stdout: SplitParser {
            onRead: data => { root._hyprlandSig = data.trim(); }
        }
    }

    // Probe NIRI_SOCKET
    Process {
        id: niriProbe
        command: ["sh", "-c", "echo \"$NIRI_SOCKET\""]
        running: true
        stdout: SplitParser {
            onRead: data => { root._niriSocket = data.trim(); }
        }
    }

    readonly property bool isHyprland: root._hyprlandSig !== ""
    readonly property bool isNiri:     !root.isHyprland && root._niriSocket !== ""
    // If neither Hyprland nor niri, assume MangoWM
    readonly property bool isMango:    !root.isHyprland && !root.isNiri

    readonly property string name: root.isHyprland ? "hyprland"
                                 : root.isNiri     ? "niri"
                                 : "mango"

    // The name of the currently focused monitor (DRM connector, e.g. "eDP-1").
    // Use this instead of Hyprland.focusedMonitor?.name for cross-compositor compat.
    readonly property string focusedMonitorName: {
        if (root.isHyprland) return Hyprland.focusedMonitor?.name ?? "";
        if (root.isMango)    return MangoData.selectedMonitor;
        if (root.isNiri)     return NiriData.activeWorkspace?.output ?? "";
        return "";
    }

    // Unified dispatch: call the right compositor's command
    // For Hyprland dispatches, uses hyprctl (caller should check compositor)
    // For Mango, calls mmsg -d
    // For Niri, currently a no-op (use NiriData directly)
    function dispatch(cmd) {
        if (root.isMango) {
            MangoData.dispatch(cmd);
        }
        // Hyprland: use Hyprland.dispatch() directly (Quickshell.Hyprland)
        // Niri: individual actions via NiriData
    }

    // Unified workspace / tag switch
    function switchWorkspace(id) {
        if (root.isMango) {
            MangoData.switchTag(id);
        } else if (root.isNiri) {
            NiriData.switchWorkspace(id);
        }
        // Hyprland: Hyprland.dispatch("workspace " + id)
    }

    function switchWorkspaceRelative(delta) {
        if (root.isMango) {
            MangoData.switchTagRelative(delta);
        } else if (root.isNiri) {
            NiriData.switchWorkspaceRelative(delta);
        }
        // Hyprland: Hyprland.dispatch("workspace r+" + delta) etc
    }
}
