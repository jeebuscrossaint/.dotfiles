import qs
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.common.widgets
import qs.services
import QtQuick
import Quickshell
import Quickshell.Services.UPower

AndroidQuickToggleButton {
    id: root
    toggleModel: TunedService.available ? tunedToggle : powerProfilesToggle

    TunedToggle { id: tunedToggle }
    PowerProfilesToggle { id: powerProfilesToggle }

    // Always open the full profile list on click when tuned-adm is available
    onClicked: {
        if (TunedService.available) {
            root.openMenu();
        } else {
            root.mainAction();
        }
    }
}
