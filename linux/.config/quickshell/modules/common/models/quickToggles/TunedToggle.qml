import QtQuick
import qs.services
import qs.modules.common

QuickToggleModel {
    id: root

    name: "Performance Profile"
    icon: TunedService.available
        ? TunedService.iconForProfile(TunedService.activeProfile)
        : "airwave"
    statusText: TunedService.available
        ? TunedService.activeProfile
        : ""
    toggled: {
        const p = TunedService.activeProfile.toLowerCase();
        return !(p.includes("powersave") || p.includes("power-save")
              || p.includes("saving")    || p === "balanced"
              || p === "");
    }
    available: true
    hasMenu: TunedService.available
    tooltipText: TunedService.available
        ? "Click to see all profiles"
        : "Click to cycle power profiles"

    // mainAction not used when tuned is available — onClicked in
    // AndroidPowerProfileToggle always opens the dialog instead.
    mainAction: () => {}
}
