import qs.services
import qs.modules.common
import qs.modules.common.widgets

import QtQuick
import QtQuick.Layouts
import qs.modules.ii.bar

StyledPopup {
    id: root

    function shortDayName(dateStr) {
        const d = new Date(dateStr + "T12:00:00");
        return ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][d.getDay()];
    }

    function formatHour(timeStr) {
        const h = parseInt(timeStr) / 100;
        if (h === 0) return "12am";
        if (h < 12) return h + "am";
        if (h === 12) return "12pm";
        return (h - 12) + "pm";
    }

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 8

        // Header
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6
                MaterialSymbol {
                    fill: 0; font.weight: Font.Medium; text: "location_on"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnSurfaceVariant
                }
                StyledText {
                    text: Weather.data.city
                    font { weight: Font.Medium; pixelSize: Appearance.font.pixelSize.normal }
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnSurfaceVariant
                text: Weather.data.temp + "  •  " + Translation.tr("Feels like %1").arg(Weather.data.tempFeelsLike)
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
                visible: Weather.data.desc !== ""
                text: Weather.data.desc + "   ↓" + Weather.data.minTemp + "  avg " + Weather.data.avgTemp + "  ↑" + Weather.data.maxTemp
            }
        }

        // Hourly strip for today
        RowLayout {
            spacing: 4
            Layout.fillWidth: true
            visible: Weather.data.hourly && Weather.data.hourly.length > 0

            Repeater {
                model: Weather.data.hourly ?? []
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colSurfaceContainerHigh
                    Layout.fillWidth: true
                    implicitHeight: hourlyCol.implicitHeight + 6 * 2

                    ColumnLayout {
                        id: hourlyCol
                        anchors.centerIn: parent
                        spacing: 1

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.formatHour(modelData.time)
                            font.pixelSize: Appearance.font.pixelSize.smaller - 1
                            color: Appearance.colors.colSubtext
                        }
                        MaterialSymbol {
                            Layout.alignment: Qt.AlignHCenter
                            fill: 0
                            text: Icons.getWeatherIcon(modelData.wCode) ?? "cloud"
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.temp
                            font.pixelSize: Appearance.font.pixelSize.smaller - 1
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.rain
                            font.pixelSize: Appearance.font.pixelSize.smaller - 1
                            color: Appearance.colors.colSubtext
                            visible: modelData.rain !== "0%"
                        }
                    }
                }
            }
        }

        // Metrics grid — 3 columns, 6 rows = 18 cards
        GridLayout {
            columns: 3
            rowSpacing: 5
            columnSpacing: 5
            uniformCellWidths: true

            WeatherCard { title: Translation.tr("UV Index");       symbol: "wb_sunny";        value: Weather.data.uv }
            WeatherCard { title: Translation.tr("Humidity");       symbol: "humidity_low";    value: Weather.data.humidity }
            WeatherCard { title: Translation.tr("Cloud Cover");    symbol: "cloud";           value: Weather.data.cloudCover }
            WeatherCard { title: Translation.tr("Wind");           symbol: "air";             value: "(" + Weather.data.windDir + ") " + Weather.data.wind }
            WeatherCard { title: Translation.tr("Wind Gust");      symbol: "cyclone";         value: Weather.data.windGust }
            WeatherCard { title: Translation.tr("Rain Chance");    symbol: "rainy";           value: Weather.data.chanceOfRain }
            WeatherCard { title: Translation.tr("Precipitation");  symbol: "rainy_light";     value: Weather.data.precip }
            WeatherCard { title: Translation.tr("Dew Point");      symbol: "water_drop";      value: Weather.data.dewPoint }
            WeatherCard { title: Translation.tr("Visibility");     symbol: "visibility";      value: Weather.data.visib }
            WeatherCard { title: Translation.tr("Pressure");       symbol: "readiness_score"; value: Weather.data.press }
            WeatherCard { title: Translation.tr("Heat Index");     symbol: "thermostat";      value: Weather.data.heatIndex }
            WeatherCard { title: Translation.tr("Wind Chill");     symbol: "ac_unit";         value: Weather.data.windChill }
            WeatherCard { title: Translation.tr("Sunrise");        symbol: "wb_twilight";     value: Weather.data.sunrise }
            WeatherCard { title: Translation.tr("Sunset");         symbol: "bedtime";         value: Weather.data.sunset }
            WeatherCard { title: Translation.tr("Sun Hours");      symbol: "sunny";           value: Weather.data.sunHours }
            WeatherCard { title: Translation.tr("Thunder");        symbol: "thunderstorm";    value: Weather.data.chanceOfThunder }
            WeatherCard { title: Translation.tr("Snow Chance");    symbol: "weather_snowy";   value: Weather.data.chanceOfSnow }
            WeatherCard { title: Translation.tr("Sunshine");       symbol: "light_mode";      value: Weather.data.chanceOfSunshine }
        }

        // 3-day forecast
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            visible: Weather.data.forecast && Weather.data.forecast.length > 0

            Repeater {
                model: Weather.data.forecast ?? []
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    radius: Appearance.rounding.small
                    color: index === 0 ? Appearance.colors.colPrimaryContainer : Appearance.colors.colSurfaceContainerHigh
                    Layout.fillWidth: true
                    implicitHeight: forecastCol.implicitHeight + 10 * 2

                    property color fgColor: index === 0 ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnSurfaceVariant
                    property color fgSubColor: index === 0 ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext

                    ColumnLayout {
                        id: forecastCol
                        anchors.centerIn: parent
                        spacing: 2

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: index === 0 ? Translation.tr("Today") : root.shortDayName(modelData.date)
                            font { pixelSize: Appearance.font.pixelSize.smaller; weight: Font.Medium }
                            color: parent.parent.fgColor
                        }
                        MaterialSymbol {
                            Layout.alignment: Qt.AlignHCenter
                            fill: 0
                            text: Icons.getWeatherIcon(modelData.wCode) ?? "cloud"
                            iconSize: Appearance.font.pixelSize.larger
                            color: parent.parent.fgColor
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "↑" + modelData.maxTemp
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: parent.parent.fgColor
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.avgTemp
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: parent.parent.fgColor
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "↓" + modelData.minTemp
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: parent.parent.fgSubColor
                        }
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2
                            MaterialSymbol {
                                fill: 0; text: "water_drop"
                                iconSize: Appearance.font.pixelSize.smaller
                                color: parent.parent.parent.fgSubColor
                            }
                            StyledText {
                                text: modelData.chanceOfRain
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: parent.parent.parent.fgSubColor
                            }
                        }
                    }
                }
            }
        }

        // Footer
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Translation.tr("Last refresh: %1").arg(Weather.data.lastRefresh)
            font { weight: Font.Medium; pixelSize: Appearance.font.pixelSize.smaller }
            color: Appearance.colors.colOnSurfaceVariant
        }
    }
}
