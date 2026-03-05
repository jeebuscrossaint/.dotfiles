import QtQuick
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property bool colorize: false
    property color color
    property string source: ""
    property string iconFolder: Qt.resolvedUrl(Quickshell.shellPath("assets/icons"))  // The folder to check first
    width: 30
    height: 30
    
    IconImage {
        id: iconImage
        anchors.fill: parent
        visible: status === Image.Ready
        // Always load from local assets folder with .svg extension.
        // Falls back to the raw name (Qt icon theme) only when no iconFolder is set.
        source: root.source
            ? (iconFolder ? iconFolder + "/" + root.source + ".svg" : root.source)
            : ""
        implicitSize: root.height
    }

    Loader {
        active: root.colorize && iconImage.status === Image.Ready
        anchors.fill: iconImage
        sourceComponent: ColorOverlay {
            source: iconImage
            color: root.color
        }
    }
}
