/*
 * Copyright (C) 2017 Jussi Nieminen, Finland
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.3
import MapboxMap 1.0
import harbour.laufhelden 1.0
import "../tools/JSTools.js" as JSTools
import "../tools/SharedResources.js" as SharedResources
import com.pipacs.o2 1.0

Page {
    id: stravaSegmentPage
    property bool busy: false
    property var effort
    property var vTrackLinePoints
    property var segment

    //Map buttons
    property bool showSettingsButton: true
    property bool showMinMaxButton: true
    property bool showCenterButton: true
    property bool bMapMaximized: false
    property bool bDisableMap: settings.mapDisableRecordPage


    O2 {
        id: o2strava
        clientId: STRAVA_CLIENT_ID
        clientSecret: STRAVA_CLIENT_SECRET
        scope: "write"
        requestUrl: "https://www.strava.com/oauth/authorize"
        tokenUrl: "https://www.strava.com/oauth/token"
    }


    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        visible: parent.busy
        running: parent.busy
    }

    SilicaFlickable
    {
        anchors.fill: parent

        VerticalScrollDecorator{}

        Column
        {
            width: parent.width
            PageHeader
            {
                id: header
                title: effort.name === "" ? "-" : effort.name
                Behavior on opacity {
                    FadeAnimation {}
                }
            }
            Grid
            {
                id: gridContainer
                x: Theme.paddingLarge
                width: parent.width
                spacing: Theme.paddingMedium
                columns: 2
                opacity: 0.2
                Behavior on opacity
                {
                    FadeAnimation {}
                }
                Label
                {
                    width: parent.width / 3
                    height:durationData.height
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignBottom
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Duration:")
                }
                Label
                {
                    id: durationData
                    width: descriptionData.width
                    text: JSTools.fncCovertMinutesToString(effort.elapsed_time)
                }
                Label
                {
                    width: parent.width / 3
                    height:distanceData.height
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignBottom
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Distance:")
                }
                Label
                {
                    id: distanceData
                    width: descriptionData.width
                    text: (settings.measureSystem === 0) ? ((effort.distance/1000).toFixed(2) + " km") : (JSTools.fncConvertDistanceToImperial(effort.distance/1000).toFixed(2) + " mi")
                }

                Label
                {
                    width: parent.width / 3
                    id: elevLabel
                    height:heartRateData.height
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignBottom
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Elevation Diff:")
                }
                Label
                {
                    id: elevData
                    width: descriptionData.width
                    text: (settings.measureSystem === 0) ? ((effort.segment.elevation_high - effort.segment.elevation_low).toFixed(2) + " m") : (JSTools.fncConvertDistanceToImperial(effort.segment.elevation_high - effort.segment.elevation_low).toFixed(2) + " ft")
                }
                Label
                {
                    width: parent.width / 3
                    id: climbLabel
                    height:heartRateData.height
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignBottom
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Climb Category:")
                }
                Label
                {
                    id: climbData
                    width: descriptionData.width
                    text: segment.climb_category
                }
                Label
                {
                    width: parent.width / 3
                    id: bestLabel
                    height:heartRateData.height
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignBottom
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Best Effort:")
                }
                Label
                {
                    id: bestData
                    width: descriptionData.width
                    text: JSTools.fncCovertMinutesToString(segment.athlete_segment_stats.pr_elapsed_time) + " on " + segment.athlete_segment_stats.pr_date
                }
            }
        }
    }
    MapboxMap
    {
        id: map

        width: parent.width
        height: bMapMaximized ? stravaSegmentPage.height : stravaSegmentPage.height / 2
        anchors.bottom: parent.bottom

        center: QtPositioning.coordinate(51.9854, 9.2743)
        zoomLevel: 8.0
        minimumZoomLevel: 0
        maximumZoomLevel: 20
        pixelRatio: 3.0

        accessToken: "pk.eyJ1IjoiamRyZXNjaGVyIiwiYSI6ImNqYmVta256YTJsdjUzMm1yOXU0cmxibGoifQ.JiMiONJkWdr0mVIjajIFZQ"
        cacheDatabaseMaximalSize: (settings.mapCache)*1024*1024
        cacheDatabaseDefaultPath: true

        styleUrl: settings.mapStyle

        visible: !bDisableMap

        Behavior on height {
            NumberAnimation { duration: 150 }
        }

        Item
        {
            id: centerButton
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingSmall
            width: parent.width / 10
            height: parent.width / 10
            visible: showCenterButton
            z: 200

            MouseArea
            {
                anchors.fill: parent
                onReleased:
                {
                    console.log("centerButton pressed");
                    map.fitView(vTrackLinePoints);
                }
            }
            Image
            {
                anchors.fill: parent
                source: "../img/map_btn_center.png"
            }
        }
        Item
        {
            id: minmaxButton
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.top: parent.top
            anchors.topMargin: Theme.paddingSmall
            width: parent.width / 10
            height: parent.width / 10
            visible: showMinMaxButton
            z: 200

            MouseArea
            {
                anchors.fill: parent
                onReleased:
                {
                    console.log("minmaxButton pressed");
                    bMapMaximized = !bMapMaximized;
                }
            }
            Image
            {
                anchors.fill: parent
                source: (map.height === stravaSegmentPage.height) ? "../img/map_btn_min.png" : "../img/map_btn_max.png"
            }
        }
        Item
        {
            id: settingsButton
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingSmall
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingSmall
            width: parent.width / 10
            height: parent.width / 10
            visible: showSettingsButton
            z: 200

            MouseArea
            {
                anchors.fill: parent
                onReleased:
                {
                    console.log("settingsButton pressed");
                    pageStack.push(Qt.resolvedUrl("MapSettingsPage.qml"));
                }
            }
            Image
            {
                anchors.fill: parent
                source: "../img/map_btn_settings.png"
            }
        }

        MapboxMapGestureArea
        {
            id: mouseArea
            map: map
            activeClickedGeo: true
            activeDoubleClickedGeo: true
            activePressAndHoldGeo: false

            onDoubleClicked:
            {
                //console.log("onDoubleClicked: " + mouse)
                map.setZoomLevel(map.zoomLevel + 1, Qt.point(mouse.x, mouse.y) );
            }
            onDoubleClickedGeo:
            {
                //console.log("onDoubleClickedGeo: " + geocoordinate);
                map.center = geocoordinate;
            }
        }
    }

    Item
    {
        id: scaleBar
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        height: base.height + text.height + text.anchors.bottomMargin
        opacity: 0.9
        visible: scaleWidth > 0 && !bDisableMap
        z: 100

        property real   scaleWidth: 0
        property string text: ""

        Rectangle {
            id: base
            anchors.bottom: scaleBar.bottom
            color: "#98CCFD"
            height: Math.floor(Theme.pixelRatio * 3)
            width: scaleBar.scaleWidth
        }

        Rectangle {
            anchors.bottom: base.top
            anchors.left: base.left
            color: "#98CCFD"
            height: Math.floor(Theme.pixelRatio * 10)
            width: Math.floor(Theme.pixelRatio * 3)
        }

        Rectangle {
            anchors.bottom: base.top
            anchors.right: base.right
            color: "#98CCFD"
            height: Math.floor(Theme.pixelRatio * 10)
            width: Math.floor(Theme.pixelRatio * 3)
        }

        Text {
            id: text
            anchors.bottom: base.top
            anchors.bottomMargin: Math.floor(Theme.pixelRatio * 4)
            anchors.horizontalCenter: base.horizontalCenter
            color: "black"
            font.bold: true
            font.family: "sans-serif"
            font.pixelSize: Math.round(Theme.pixelRatio * 18)
            horizontalAlignment: Text.AlignHCenter
            text: scaleBar.text
        }

        function siground(x, n) {
            // Round x to n significant digits.
            var mult = Math.pow(10, n - Math.floor(Math.log(x) / Math.LN10) - 1);
            return Math.round(x * mult) / mult;
        }

        function roundedDistace(dist)
        {
            // Return dist rounded to an even amount of user-visible units,
            // but keeping the value as meters.

            if (settings.measureSystem === 0)
            {
                return siground(dist, 1);
            }
            else
            {
                return dist >= 1609.34 ?
                            siground(dist / 1609.34, 1) * 1609.34 :
                            siground(dist * 3.28084, 1) / 3.28084;
            }
        }

        function update()
        {
            // Update scalebar for current zoom level and latitude.

            var meters = map.metersPerPixel * map.width / 4;
            var dist = scaleBar.roundedDistace(meters);

            scaleBar.scaleWidth = dist / map.metersPerPixel

            console.log("dist: " + dist);

            var sUnit = "";
            var iDistance = 0;

            if (settings.measureSystem === 0)
            {
                sUnit = "m";
                iDistance = Math.ceil(dist);
                if (dist >= 1000)
                {
                    sUnit = "km";
                    iDistance = dist / 1000.0;
                    iDistance = Math.ceil(iDistance);
                }
            }
            else
            {
                dist = dist * 3.28084;  //convert to feet

                sUnit = "ft";
                iDistance = Math.ceil(dist);
                if (dist >= 5280)
                {
                    sUnit = "mi";
                    iDistance = dist / 5280.0;
                    iDistance = Math.ceil(iDistance);
                }
            }

            scaleBar.text = iDistance.toString() + " " + sUnit
        }

        Connections
        {
            target: map
            onMetersPerPixelChanged: scaleBar.update()
            onWidthChanged: scaleBar.update()
        }
    }

    function loadSegment(id){

        console.log("Loading segment ", id);

        if (!o2strava.linked){
            console.log("Not linked to Strava");
            return;
        }
        busy = true;

        var xmlhttp = new XMLHttpRequest();

        JSTools.stravaGet(xmlhttp, "https://www.strava.com/api/v3/segments/" + id, o2strava.token , function(){
            busy = true;
            //console.log("Ready state changed:", xmlhttp.readyState, xmlhttp.responseType, xmlhttp.responseText, xmlhttp.status, xmlhttp.statusText);
            if (xmlhttp.readyState==4 && xmlhttp.status==200){
                //console.log("Get Response:", xmlhttp.responseText);
                segment = JSON.parse(xmlhttp.responseText);

                addSegmentToMap();
            }
            busy = false;
            gridContainer.opacity = 1.0
            map.opacity = 1.0
        });
    }

    function addSegmentToMap()
    {
        if (!bDisableMap) {
            //This is the actialy activity route
            vTrackLinePoints = decode(segment.map.polyline);
            map.addSourceLine("linesrc", vTrackLinePoints, "line")

            map.addLayer("line", { "type": "line", "source": "linesrc" })
            map.setLayoutProperty("line", "line-join", "round");
            map.setLayoutProperty("line", "line-cap", "round");
            map.setPaintProperty("line", "line-color", "red");
            map.setPaintProperty("line", "line-width", 2.0);

            map.fitView(vTrackLinePoints);

            //This is the start point of the activity
            //map.addSourcePoint("pointStartImage",  QtPositioning.coordinate(activity.start_latlng[0],activity.start_latlng[1]));
            map.addSourcePoint("pointStartImage",  vTrackLinePoints[0]);
            map.addImagePath("imageStartImage", Qt.resolvedUrl("../img/map_play.png"));
            map.addLayer("layerStartLayer", {"type": "symbol", "source": "pointStartImage"});
            map.setLayoutProperty("layerStartLayer", "icon-image", "imageStartImage");
            map.setLayoutProperty("layerStartLayer", "icon-size", 1.0 / map.pixelRatio);
            map.setLayoutProperty("layerStartLayer", "visibility", "visible");

            //This is the end point of the activity
           // map.addSourcePoint("pointEndImage",  QtPositioning.coordinate(activity.end_latlng[0],activity.end_latlng[1]));
            map.addSourcePoint("pointEndImage",  vTrackLinePoints[vTrackLinePoints.length - 1]);
            map.addImagePath("imageEndImage", Qt.resolvedUrl("../img/map_stop.png"));
            map.addLayer("layerEndLayer", {"type": "symbol", "source": "pointEndImage"});
            map.setLayoutProperty("layerEndLayer", "icon-image", "imageEndImage");
            map.setLayoutProperty("layerEndLayer", "icon-size", 1.0 / map.pixelRatio);
            map.setLayoutProperty("layerEndLayer", "visibility", "visible");
        }
    }

    function decode(encoded){

        // array that holds the points

        var points=[ ]
        var index = 0, len = encoded.length;
        var lat = 0, lng = 0;
        while (index < len) {
            var b, shift = 0, result = 0;
            do {

                b = encoded.charAt(index++).charCodeAt(0) - 63;//finds ascii                                                                                    //and substract it by 63
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);


            var dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
            lat += dlat;
            shift = 0;
            result = 0;
            do {
                b = encoded.charAt(index++).charCodeAt(0) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            var dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
            lng += dlng;

            points.push(QtPositioning.coordinate(( lat / 1E5), ( lng / 1E5)));
        }
        return points
    }
}
