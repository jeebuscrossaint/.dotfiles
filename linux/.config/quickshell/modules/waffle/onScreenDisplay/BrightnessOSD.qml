import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.modules.waffle.looks

OSDValue {
    id: root
    property var focusedScreen: Quickshell.screens.find(s => s.name === Compositor.focusedMonitorName)
    property var brightnessMonitor: Brightness.getMonitorForScreen(focusedScreen)
    iconName: "weather-sunny"
    value: brightnessMonitor?.brightness ?? 0
    showNumber: false

    Connections {
        target: Brightness
        function onBrightnessChanged() {
            root.timer.restart();
        }
    }
}
