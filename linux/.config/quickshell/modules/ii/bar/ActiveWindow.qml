import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root
    // For Hyprland: use native monitor API
    readonly property HyprlandMonitor hyprMonitor: Compositor.isHyprland
        ? Hyprland.monitorFor(root.QsWindow.window?.screen)
        : null
    readonly property string monitorName: root.QsWindow.window?.screen?.name ?? ""
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    // Whether the focused window is on the monitor shown by this bar instance
    readonly property bool focusingThisMonitor: {
        if (Compositor.isHyprland) {
            return HyprlandData.activeWorkspace?.monitor === root.hyprMonitor?.name;
        }
        if (Compositor.isMango) {
            return MangoData.selectedMonitor === root.monitorName
                || MangoData.monitorNames.length <= 1;
        }
        return true; // niri: just show current focus
    }

    // The biggest/most relevant window to show info about
    readonly property var biggestWindow: {
        if (Compositor.isHyprland) {
            const monId = root.hyprMonitor?.id;
            return HyprlandData.biggestWindowForWorkspace(
                HyprlandData.monitors[monId]?.activeWorkspace.id
            );
        }
        return MangoData.biggestWindowForWorkspace(0);
    }

    // App id and title strings (compositor-agnostic)
    readonly property string displayAppId: {
        if (root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow)
            return root.activeWindow?.appId ?? "";
        if (Compositor.isMango) return MangoData.focusedAppId;
        if (Compositor.isNiri)  return NiriData.focusedAppId;
        return root.biggestWindow?.class ?? "";
    }
    readonly property string displayTitle: {
        if (root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow)
            return root.activeWindow?.title ?? "";
        if (Compositor.isMango) return MangoData.focusedTitle;
        if (Compositor.isNiri)  return NiriData.focusedTitle;
        return root.biggestWindow?.title ?? `${Translation.tr("Workspace")} ${root.hyprMonitor?.activeWorkspace?.id ?? 1}`;
    }

    implicitWidth: colLayout.implicitWidth

    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: -4

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
            text: root.displayAppId || Translation.tr("Desktop")
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer0
            elide: Text.ElideRight
            text: root.displayTitle || Translation.tr("Desktop")        }
    }
}