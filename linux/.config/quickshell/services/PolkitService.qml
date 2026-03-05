pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

// Quickshell.Services.Polkit is not installed — stub out the service.
// Install the polkit quickshell module to enable authentication popups.
Singleton {
    id: root
    property var agent: null
    property bool active: false
    property var flow: null
    property bool interactionAvailable: false
    property string cleanMessage: ""
    property string cleanPrompt: ""

    function cancel() {}
    function submit(s) {}
}
