import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property Item hoverTarget
    property bool open: false
    property int brightness: 0
    property int maxBrightness: 3
    readonly property string ledPath: "/sys/class/leds/asus::kbd_backlight"

    function setBrightness(val) {
        writeProc.target = val
        writeProc.running = true
        brightness = val
    }

    Process {
        id: readProc
        command: ["cat", root.ledPath + "/brightness"]
        stdout: StdioCollector {
            id: readOut
            onStreamFinished: {
                const val = parseInt(readOut.text.trim())
                if (!isNaN(val)) root.brightness = val
            }
        }
    }

    Process {
        id: writeProc
        property int target: 0
        command: ["brightnessctl", "-d", "asus::kbd_backlight", "set", String(writeProc.target)]
        onExited: readProc.running = true
    }

    StyledPopup {
        id: kbdPopup
        hoverTarget: root.hoverTarget
        open: root.open
        onOpenChanged: if (open) readProc.running = true

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6

            StyledPopupHeaderRow {
                icon: "keyboard"
                label: "Keyboard Backlight"
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Appearance.colors.colLayer0Border
            }

            RowLayout {
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.bottomMargin: 6
                spacing: 6

                Repeater {
                    model: root.maxBrightness + 1

                    delegate: RippleButton {
                        required property int index
                        implicitWidth: 44
                        implicitHeight: 36
                        buttonRadius: Appearance.rounding.small
                        colBackground: index === root.brightness
                            ? Appearance.colors.colPrimary
                            : Appearance.colors.colLayer1
                        onClicked: root.setBrightness(index)

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            MaterialSymbol {
                                Layout.alignment: Qt.AlignHCenter
                                text: index === 0 ? "keyboard_off" : "keyboard"
                                iconSize: Appearance.font.pixelSize.normal
                                fill: index > 0 ? 1 : 0
                                color: index === root.brightness
                                    ? Appearance.colors.colOnPrimary
                                    : Appearance.colors.colOnLayer1
                            }
                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: index === 0 ? "off" : String(index)
                                font.pixelSize: 9
                                color: index === root.brightness
                                    ? Appearance.colors.colOnPrimary
                                    : Appearance.colors.colSubtext
                            }
                        }
                    }
                }
            }
        }
    }
}
