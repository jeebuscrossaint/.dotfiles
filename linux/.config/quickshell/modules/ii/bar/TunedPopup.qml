import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 3

        // ── Header ──────────────────────────────────────────────────────
        StyledPopupHeaderRow {
            icon: "tune"
            label: "Performance Profile"
        }

        // ── Divider ──────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Appearance.colors.colLayer0Border
        }

        // ── Profile list (scrollable) ─────────────────────────────────
        Item {
            id: listArea
            // implicitWidth drives the popup's width
            implicitWidth: 230
            implicitHeight: Math.min(profileCol.implicitHeight, 280)
            Layout.fillWidth: true
            clip: true

            Flickable {
                id: flickable
                anchors.fill: parent
                contentWidth: listArea.implicitWidth
                contentHeight: profileCol.implicitHeight
                clip: true
                boundsMovement: Flickable.StopAtBounds
                // Scroll with mouse wheel even when not focused
                WheelHandler {
                    target: flickable
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        flickable.contentY = Math.max(0, Math.min(
                            flickable.contentY - event.angleDelta.y / 3,
                            flickable.contentHeight - flickable.height
                        ))
                    }
                }

                Column {
                    id: profileCol
                    width: listArea.implicitWidth
                    spacing: 1

                    Repeater {
                        model: TunedService.profiles
                        delegate: RippleButton {
                            id: row
                            required property string modelData
                            readonly property bool isActive: modelData === TunedService.activeProfile

                            width: listArea.implicitWidth
                            implicitHeight: 32
                            buttonRadius: Appearance.rounding.small

                            // Active row shows a filled highlight; non-active rows are transparent
                            colBackground: "transparent"
                            toggled: row.isActive

                            enabled: !TunedService.switching
                            opacity: TunedService.switching && !row.isActive ? 0.5 : 1.0
                            onClicked: TunedService.setProfile(row.modelData)

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 8
                                    rightMargin: 8
                                }
                                spacing: 6

                                MaterialSymbol {
                                    text: TunedService.iconForProfile(row.modelData)
                                    iconSize: Appearance.font.pixelSize.normal
                                    color: row.isActive
                                        ? Appearance.m3colors.m3primary
                                        : Appearance.colors.colOnSurfaceVariant
                                    Behavior on color {
                                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: row.modelData
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: row.isActive ? Font.Medium : Font.Normal
                                    color: row.isActive
                                        ? Appearance.m3colors.m3primary
                                        : Appearance.colors.colOnLayer1
                                    elide: Text.ElideRight
                                    Behavior on color {
                                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                                    }
                                }

                                MaterialSymbol {
                                    visible: row.isActive
                                    text: "check"
                                    iconSize: Appearance.font.pixelSize.normal
                                    color: Appearance.m3colors.m3primary
                                }
                            }
                        }
                    }
                }
            }

            // Thin scroll thumb on the right edge
            Rectangle {
                visible: flickable.contentHeight > flickable.height
                anchors.right: parent.right
                anchors.rightMargin: 1
                width: 3
                radius: 2
                color: Appearance.colors.colOutlineVariant
                opacity: 0.7
                height: Math.max(16, flickable.height * flickable.height / flickable.contentHeight)
                y: (flickable.contentHeight > flickable.height)
                   ? flickable.contentY / (flickable.contentHeight - flickable.height) * (flickable.height - height)
                   : 0
            }
        }

        // ── "Applying…" status ───────────────────────────────────────────
        StyledText {
            visible: TunedService.switching
            Layout.alignment: Qt.AlignHCenter
            text: "Applying…"
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnSurfaceVariant
        }
    }
}
