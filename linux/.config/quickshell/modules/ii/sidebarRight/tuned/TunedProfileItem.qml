import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

DialogListItem {
    id: root
    required property string profileName
    readonly property bool isActive: profileName === TunedService.activeProfile

    active: isActive
    enabled: !TunedService.switching
    opacity: TunedService.switching && !isActive ? 0.5 : 1.0
    onClicked: TunedService.setProfile(profileName)

    contentItem: RowLayout {
        spacing: 10

        MaterialSymbol {
            iconSize: Appearance.font.pixelSize.larger
            text: TunedService.iconForProfile(root.profileName)
            fill: root.isActive ? 1 : 0
            color: root.isActive
                ? Appearance.m3colors.m3primary
                : Appearance.colors.colOnSurfaceVariant
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }

        StyledText {
            Layout.fillWidth: true
            color: root.isActive
                ? Appearance.m3colors.m3primary
                : Appearance.colors.colOnSurfaceVariant
            font.weight: root.isActive ? Font.Medium : Font.Normal
            elide: Text.ElideRight
            text: root.profileName
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }

        MaterialSymbol {
            visible: root.isActive
            text: "check"
            iconSize: Appearance.font.pixelSize.larger
            color: Appearance.m3colors.m3primary
        }
    }
}
