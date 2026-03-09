pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtPositioning

import qs.modules.common

Singleton {
    id: root
    // 10 minute
    readonly property int fetchInterval: Config.options.bar.weather.fetchInterval * 60 * 1000
    readonly property string city: Config.options.bar.weather.city
    readonly property bool useUSCS: Config.options.bar.weather.useUSCS
    property bool gpsActive: Config.options.bar.weather.enableGPS
    property bool fetching: false

    onUseUSCSChanged: {
        root.getData();
    }
    onCityChanged: {
        root.getData();
    }

    property var location: ({
        valid: false,
        lat: 0,
        lon: 0
    })

    property var data: ({
        uv: 0,
        humidity: "0%",
        sunrise: "0.0",
        sunset: "0.0",
        windDir: "N",
        wCode: 0,
        city: "City",
        wind: "0",
        windGust: "0",
        precip: "0",
        visib: "0",
        press: "0",
        temp: "0",
        tempFeelsLike: "0",
        cloudCover: "0%",
        desc: "",
        dewPoint: "0",
        chanceOfRain: "0%",
        chanceOfThunder: "0%",
        chanceOfSnow: "0%",
        chanceOfFog: "0%",
        chanceOfSunshine: "0%",
        heatIndex: "0",
        windChill: "0",
        avgTemp: "0",
        sunHours: "0",
        totalSnow: "0",
        maxTemp: "0",
        minTemp: "0",
        forecast: [],
        hourly: [],
        lastRefresh: 0,
    })

    function refineData(data) {
        let temp = {};
        temp.uv = data?.current?.uvIndex || 0;
        temp.humidity = (data?.current?.humidity || 0) + "%";
        temp.sunrise = data?.astronomy?.sunrise || "0.0";
        temp.sunset = data?.astronomy?.sunset || "0.0";
        temp.windDir = data?.current?.winddir16Point || "N";
        temp.wCode = data?.current?.weatherCode || "113";
        temp.city = data?.location?.areaName[0]?.value || "City";
        temp.cloudCover = (data?.current?.cloudcover || 0) + "%";
        temp.desc = data?.current?.weatherDesc?.[0]?.value || "";
        temp.chanceOfRain = (data?.forecast?.[0]?.chanceofrain || 0) + "%";
        temp.chanceOfThunder = (data?.midday?.chanceofthunder || 0) + "%";
        temp.chanceOfSnow = (data?.midday?.chanceofsnow || 0) + "%";
        temp.chanceOfFog = (data?.midday?.chanceoffog || 0) + "%";
        temp.chanceOfSunshine = (data?.midday?.chanceofsunshine || 0) + "%";
        temp.sunHours = (data?.forecast?.[0]?.sunHour || 0) + " hrs";
        temp.totalSnow = (data?.forecast?.[0]?.totalSnow_cm || 0) + " cm";
        temp.temp = "";
        temp.tempFeelsLike = "";
        if (root.useUSCS) {
            temp.wind = (data?.current?.windspeedMiles || 0) + " mph";
            temp.windGust = (data?.midday?.WindGustMiles || 0) + " mph";
            temp.precip = (data?.current?.precipInches || 0) + " in";
            temp.visib = (data?.current?.visibilityMiles || 0) + " mi";
            temp.press = (data?.current?.pressureInches || 0) + " psi";
            temp.temp += (data?.current?.temp_F || 0);
            temp.tempFeelsLike += (data?.current?.FeelsLikeF || 0);
            temp.temp += "°F";
            temp.tempFeelsLike += "°F";
            temp.dewPoint = (data?.midday?.DewPointF || 0) + "°F";
            temp.heatIndex = (data?.midday?.HeatIndexF || 0) + "°F";
            temp.windChill = (data?.midday?.WindChillF || 0) + "°F";
            temp.avgTemp = (data?.forecast?.[0]?.avgtempF || 0) + "°F";
            temp.maxTemp = (data?.forecast?.[0]?.maxtempF || 0) + "°F";
            temp.minTemp = (data?.forecast?.[0]?.mintempF || 0) + "°F";
            temp.hourly = (data?.hourly || []).map(h => ({
                time: h.time,
                wCode: h.wCode,
                temp: h.tempF + "°F",
                rain: h.chanceofrain + "%"
            }));
            temp.forecast = (data?.forecast || []).map(d => ({
                date: d.date,
                wCode: d.wCode,
                minTemp: d.mintempF + "°F",
                maxTemp: d.maxtempF + "°F",
                avgTemp: d.avgtempF + "°F",
                chanceOfRain: d.chanceofrain + "%"
            }));
        } else {
            temp.wind = (data?.current?.windspeedKmph || 0) + " km/h";
            temp.windGust = (data?.midday?.WindGustKmph || 0) + " km/h";
            temp.precip = (data?.current?.precipMM || 0) + " mm";
            temp.visib = (data?.current?.visibility || 0) + " km";
            temp.press = (data?.current?.pressure || 0) + " hPa";
            temp.temp += (data?.current?.temp_C || 0);
            temp.tempFeelsLike += (data?.current?.FeelsLikeC || 0);
            temp.temp += "°C";
            temp.tempFeelsLike += "°C";
            temp.dewPoint = (data?.midday?.DewPointC || 0) + "°C";
            temp.heatIndex = (data?.midday?.HeatIndexC || 0) + "°C";
            temp.windChill = (data?.midday?.WindChillC || 0) + "°C";
            temp.avgTemp = (data?.forecast?.[0]?.avgtempC || 0) + "°C";
            temp.maxTemp = (data?.forecast?.[0]?.maxtempC || 0) + "°C";
            temp.minTemp = (data?.forecast?.[0]?.mintempC || 0) + "°C";
            temp.hourly = (data?.hourly || []).map(h => ({
                time: h.time,
                wCode: h.wCode,
                temp: h.tempC + "°C",
                rain: h.chanceofrain + "%"
            }));
            temp.forecast = (data?.forecast || []).map(d => ({
                date: d.date,
                wCode: d.wCode,
                minTemp: d.mintempC + "°C",
                maxTemp: d.maxtempC + "°C",
                avgTemp: d.avgtempC + "°C",
                chanceOfRain: d.chanceofrain + "%"
            }));
        }
        temp.lastRefresh = DateTime.time + " • " + DateTime.date;
        root.data = temp;
    }

    function getData() {
        root.fetching = true;
        let command = "curl -s wttr.in";

        if (root.gpsActive && root.location.valid) {
            command += `/${root.location.lat},${root.location.long}`;
        } else {
            command += `/${formatCityName(root.city)}`;
        }

        // format as json
        command += "?format=j1";
        command += " | ";
        // only take what we need
        command += "jq '{current: .current_condition[0], location: .nearest_area[0], astronomy: .weather[0].astronomy[0], midday: .weather[0].hourly[4], hourly: [.weather[0].hourly[] | {time: .time, wCode: .weatherCode, tempC: .tempC, tempF: .tempF, chanceofrain: .chanceofrain}], forecast: [.weather[] | {date: .date, maxtempC: .maxtempC, maxtempF: .maxtempF, mintempC: .mintempC, mintempF: .mintempF, avgtempC: .avgtempC, avgtempF: .avgtempF, sunHour: .sunHour, totalSnow_cm: .totalSnow_cm, wCode: .hourly[4].weatherCode, chanceofrain: ([.hourly[].chanceofrain | tonumber] | max)}]}'";
        fetcher.command[2] = command;
        fetcher.running = true;
    }

    function formatCityName(cityName) {
        return cityName.trim().split(/\s+/).join('+');
    }

    Component.onCompleted: {
        if (!root.gpsActive) return;
        console.info("[WeatherService] Starting the GPS service.");
        positionSource.start();
    }

    Process {
        id: fetcher
        command: ["bash", "-c", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) {
                    console.warn("[WeatherService] Empty response, retrying in 30s");
                    root.fetching = false;
                    retryTimer.restart();
                    return;
                }
                try {
                    const parsedData = JSON.parse(text);
                    root.refineData(parsedData);
                    root.fetching = false;
                    retryTimer.stop();
                } catch (e) {
                    console.error(`[WeatherService] ${e.message}`);
                    root.fetching = false;
                    retryTimer.restart();
                }
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 30000 // 30 seconds
        repeat: false
        onTriggered: root.getData()
    }

    PositionSource {
        id: positionSource
        updateInterval: root.fetchInterval

        onPositionChanged: {
            // update the location if the given location is valid
            // if it fails getting the location, use the last valid location
            if (position.latitudeValid && position.longitudeValid) {
                root.location.lat = position.coordinate.latitude;
                root.location.long = position.coordinate.longitude;
                root.location.valid = true;
                // console.info(`📍 Location: ${position.coordinate.latitude}, ${position.coordinate.longitude}`);
                root.getData();
                // if can't get initialized with valid location deactivate the GPS
            } else {
                root.gpsActive = root.location.valid ? true : false;
                console.error("[WeatherService] Failed to get the GPS location.");
            }
        }

        onValidityChanged: {
            if (!positionSource.valid) {
                positionSource.stop();
                root.location.valid = false;
                root.gpsActive = false;
                Quickshell.execDetached(["notify-send", Translation.tr("Weather Service"), Translation.tr("Cannot find a GPS service. Using the fallback method instead."), "-a", "Shell"]);
                console.error("[WeatherService] Could not aquire a valid backend plugin.");
            }
        }
    }

    Timer {
        running: !root.gpsActive
        repeat: true
        interval: root.fetchInterval
        triggeredOnStart: !root.gpsActive
        onTriggered: root.getData()
    }
}
