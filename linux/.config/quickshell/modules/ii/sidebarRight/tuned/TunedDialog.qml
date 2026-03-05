import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

WindowDialog {
    id: root
    backgroundHeight: 580

    WindowDialogTitle {
        text: "Performance Profile"
    }

    WindowDialogSeparator {
        visible: !TunedService.switching
    }

    StyledIndeterminateProgressBar {
        visible: TunedService.switching
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large
    }

    // Profile list
    StyledListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large

        clip: true
        spacing: 0
        animateAppearance: false

        model: ScriptModel {
            values: TunedService.profiles
        }
        delegate: TunedProfileItem {
            required property string modelData
            profileName: modelData
            anchors {
                left: parent?.left
                right: parent?.right
            }
        }
    }
}
