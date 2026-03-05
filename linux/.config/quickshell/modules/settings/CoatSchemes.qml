import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

ContentPage {
    id: root
    forceWidth: true

    property var allSchemes: []
    property var displayedSchemes: []
    property string searchText: ""
    property string variantFilter: "all"
    property string activeSlug: ""
    property bool applying: false

    function rebuildDisplay() {
        var q = searchText.toLowerCase();
        displayedSchemes = allSchemes.filter(function(s) {
            var matchVariant = variantFilter === "all" || s.variant === variantFilter;
            var matchSearch  = q === "" ||
                               s.name.toLowerCase().indexOf(q) !== -1 ||
                               s.slug.toLowerCase().indexOf(q) !== -1 ||
                               s.author.toLowerCase().indexOf(q) !== -1;
            return matchVariant && matchSearch;
        });
    }

    onAllSchemesChanged:    rebuildDisplay()
    onSearchTextChanged:    rebuildDisplay()
    onVariantFilterChanged: rebuildDisplay()

    function applyScheme(slug) {
        if (applying) return;
        applying = true;
        activeSlug = slug;
        applyProc.command = [
            FileUtils.trimFileProtocol(Directories.scriptPath) + "/colors/coat-apply.sh",
            slug
        ];
        applyProc.running = true;
    }

    Process {
        id: indexProc
        command: ["python3",
            FileUtils.trimFileProtocol(Directories.scriptPath) + "/colors/coat-schemes-index.py"]
        running: true
        stdout: StdioCollector {
            id: indexOut
            onStreamFinished: {
                try {
                    root.allSchemes = JSON.parse(indexOut.text);
                } catch(e) {
                    console.warn("CoatSchemes: parse failed:", e);
                }
            }
        }
    }

    FileView {
        id: coatYaml
        path: FileUtils.trimFileProtocol(Directories.home) + ".config/coat/coat.yaml"
        watchChanges: true
        onLoaded: {
            var m = coatYaml.text().match(/^scheme:\s*(\S+)/m);
            if (m) root.activeSlug = m[1].trim();
        }
        onFileChanged: reload()
    }

    Process {
        id: applyProc
        onExited: root.applying = false
    }

    ContentSection {
        icon: "palette"
        title: qsTr("coat Schemes")

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 36
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer2
                border.width: 1
                border.color: Appearance.colors.colLayer0Border

                RowLayout {
                    anchors { fill: parent; leftMargin: 10; rightMargin: 6 }
                    spacing: 6
                    MaterialSymbol {
                        text: "search"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                    }
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        text: root.searchText
                        onTextChanged: root.searchText = text
                        color: Appearance.colors.colOnLayer1
                        font.family: Appearance.font.family.main
                        font.pixelSize: Appearance.font.pixelSize.small
                        Text {
                            anchors.fill: parent
                            visible: searchInput.text === ""
                            text: qsTr("Search schemes...")
                            color: Appearance.colors.colSubtext
                            font: searchInput.font
                        }
                    }
                    RippleButton {
                        visible: root.searchText !== ""
                        implicitWidth: 24; implicitHeight: 24
                        buttonRadius: 12
                        colBackground: "transparent"
                        onClicked: { searchInput.text = ""; root.searchText = ""; }
                        contentItem: MaterialSymbol {
                            horizontalAlignment: Qt.AlignHCenter
                            text: "close"
                            iconSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }

            Repeater {
                model: [
                    { label: qsTr("All"),   key: "all"   },
                    { label: qsTr("Dark"),  key: "dark"  },
                    { label: qsTr("Light"), key: "light" },
                ]
                delegate: RippleButton {
                    required property var modelData
                    implicitHeight: 36
                    implicitWidth: pillLabel.implicitWidth + 24
                    buttonRadius: Appearance.rounding.small
                    toggled: root.variantFilter === modelData.key
                    colBackground: root.variantFilter === modelData.key
                        ? Appearance.colors.colPrimary
                        : Appearance.colors.colLayer2
                    onClicked: root.variantFilter = modelData.key
                    contentItem: StyledText {
                        id: pillLabel
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.label
                        color: root.variantFilter === modelData.key
                            ? Appearance.colors.colOnPrimary
                            : Appearance.colors.colOnLayer2
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            MaterialSymbol {
                text: root.applying ? "sync" : "check_circle"
                iconSize: Appearance.font.pixelSize.normal
                color: root.applying ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
            }
            StyledText {
                text: root.applying
                    ? qsTr("Applying %1...").arg(root.activeSlug)
                    : root.activeSlug !== ""
                        ? qsTr("Active: %1").arg(root.activeSlug)
                        : qsTr("No scheme selected")
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.small
            }
            Item { Layout.fillWidth: true }
            StyledText {
                text: qsTr("%1 / %2").arg(root.displayedSchemes.length).arg(root.allSchemes.length)
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: schemeGrid.contentHeight

            GridView {
                id: schemeGrid
                width: parent.width
                height: contentHeight
                model: root.displayedSchemes
                cellWidth:  168
                cellHeight: 118
                interactive: false

                delegate: Item {
                    id: card
                    required property var modelData
                    width:  schemeGrid.cellWidth
                    height: schemeGrid.cellHeight

                    RippleButton {
                        anchors { fill: parent; margins: 4 }
                        buttonRadius: Appearance.rounding.normal
                        toggled: card.modelData.slug === root.activeSlug
                        colBackground: card.modelData.slug === root.activeSlug
                            ? Appearance.colors.colSecondaryContainer
                            : Appearance.colors.colLayer1
                        colBackgroundHover: card.modelData.slug === root.activeSlug
                            ? ColorUtils.transparentize(Appearance.colors.colSecondaryContainer, 0.15)
                            : Appearance.colors.colLayer1Hover
                        onClicked: root.applyScheme(card.modelData.slug)

                        Column {
                            anchors.fill: parent
                            spacing: 0

                            Item {
                                width: parent.width
                                height: 50
                                clip: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: card.modelData.colors && card.modelData.colors.length > 0
                                        ? "#" + card.modelData.colors[0] : "#1a1a1a"
                                    radius: Appearance.rounding.normal
                                }
                                Rectangle {
                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                    height: parent.height / 2
                                    color: card.modelData.colors && card.modelData.colors.length > 0
                                        ? "#" + card.modelData.colors[0] : "#1a1a1a"
                                }
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Repeater {
                                        model: 8
                                        delegate: Rectangle {
                                            required property int index
                                            width: 16; height: 16; radius: 8
                                            border.width: 1
                                            border.color: Qt.rgba(0, 0, 0, 0.2)
                                            color: card.modelData.colors && card.modelData.colors.length > (8 + index)
                                                ? "#" + card.modelData.colors[8 + index]
                                                : "#888888"
                                        }
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                height: parent.height - 50
                                clip: true

                                Column {
                                    anchors { fill: parent; leftMargin: 8; rightMargin: 8; topMargin: 5 }
                                    spacing: 4

                                    StyledText {
                                        width: parent.width
                                        text: card.modelData.name ?? ""
                                        elide: Text.ElideRight
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        font.weight: Font.Medium
                                        color: card.modelData.slug === root.activeSlug
                                            ? Appearance.colors.colOnSecondaryContainer
                                            : Appearance.colors.colOnLayer1
                                    }

                                    Row {
                                        spacing: 4

                                        Rectangle {
                                            visible: (card.modelData.variant ?? "") !== ""
                                            width: varTxt.implicitWidth + 10
                                            height: 15; radius: 7
                                            color: card.modelData.variant === "dark"
                                                ? Qt.rgba(0, 0, 0, 0.4)
                                                : Qt.rgba(1, 1, 1, 0.45)
                                            StyledText {
                                                id: varTxt
                                                anchors.centerIn: parent
                                                text: card.modelData.variant ?? ""
                                                font.pixelSize: 9
                                                color: card.modelData.variant === "dark" ? "#cccccc" : "#333333"
                                            }
                                        }

                                        Rectangle {
                                            visible: (card.modelData.system ?? "") === "base24"
                                            width: b24.implicitWidth + 10
                                            height: 15; radius: 7
                                            color: Appearance.colors.colTertiary
                                            StyledText {
                                                id: b24
                                                anchors.centerIn: parent
                                                text: "24"
                                                font.pixelSize: 9
                                                color: Appearance.colors.colOnTertiary
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        StyledText {
            visible: root.displayedSchemes.length === 0 && root.allSchemes.length > 0
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("No schemes match your search")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.normal
        }
        StyledText {
            visible: root.allSchemes.length === 0
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Loading... (run coat clone if this stays empty)")
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.normal
        }
    }
}
