/*
    Copyright 2014 Simo Mattila
    simo.h.mattila@gmail.com

    This file is part of Rena.

    Rena is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    Rena is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Rena.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtLocation 5.0
import QtPositioning 5.0


Page {
    id: page

    function showSaveDialog() {
        var dialog = pageStack.push(Qt.resolvedUrl("SaveDialog.qml"));
        dialog.accepted.connect(function() {
            console.log("Saving track");
            recorder.exportGpx(dialog.name, dialog.description);
            recorder.clearTrack();  // TODO: Make sure save was successful?
        })
    }

    function setMapZoom() {
        var windowPixels;
        if(map.width < map.height) {
            windowPixels = map.width;
        } else {
            windowPixels = map.height;
        }
        var z=0;
        while(z<16) {
            // Earth diameter in WGS-84: 40075.016686 km
            // Tile size: 256 pixels
            var windowLength = (40075016.686 / 256.0)
                    * Math.cos(recorder.currentPosition.latitude*Math.PI/180)
                    / Math.pow(2,z) * windowPixels;
            //console.log(z+": "+windowLength);
            if(windowLength < (2*recorder.accuracy)) {
                z--;
                break;
            }
            z++;
        }
        //console.log(windowPixels+" "+windowLength+" "+2*recorder.accuracy+" "+z);
        map.zoomLevel = z;
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("HistoryPage.qml"), {})
        }
    }

    Component.onCompleted: {
        map.addMapItem(positionMarker);
    }

    MapCircle {
        id: positionMarker
        center: recorder.currentPosition
        radius: recorder.accuracy
        color: "blue"
        border.color: "blue"
        opacity: 0.3
        onRadiusChanged: setMapZoom()
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About Rena")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Start new recording")
                visible: !recorder.tracking
                onClicked: {
                    recorder.clearTrack();
                    recorder.tracking = true;
                }
            }
            MenuItem {
                text: qsTr("Continue recording")
                visible: !recorder.tracking && !recorder.isEmpty
                onClicked: recorder.tracking = true
            }
            MenuItem {
                text: qsTr("Save track")
                visible: !recorder.tracking && !recorder.isEmpty
                onClicked: showSaveDialog()
            }
            MenuItem {
                text: qsTr("Stop recording")
                visible: recorder.tracking
                onClicked: {
                    recorder.tracking = false;
                    if(!recorder.isEmpty) {
                        showSaveDialog();
                    }
                }
            }
        }

        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                id: header
                title: "Rena"
            }
            Label {
                id: stateLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: recorder.tracking ? qsTr("Recording") : qsTr("Stopped")
                font.pixelSize: Theme.fontSizeLarge
            }
            Label {
                id: distanceLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: (recorder.distance/1000).toFixed(3) + " km"
                font.pixelSize: Theme.fontSizeHuge
            }
            Label {
                id: timeLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: recorder.time
                font.pixelSize: Theme.fontSizeHuge
            }
            Label {
                id: accuracyLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: recorder.accuracy < 0 ? "No position" :
                                              (recorder.accuracy < 30
                                               ? qsTr("Accuracy: ") + recorder.accuracy.toFixed(1) + "m"
                                               : qsTr("Accuracy too low: ") + recorder.accuracy.toFixed(1) + "m")
            }
            Map {
                id: map
                width: parent.width
                height: page.height - header.height - stateLabel.height - distanceLabel.height - timeLabel.height - accuracyLabel.height - 5*Theme.paddingLarge
                zoomLevel: 15
                clip: true
                gesture.enabled: false
                plugin: Plugin {
                    name: "osm"
                }
                center: recorder.currentPosition

                MapQuickItem {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    sourceItem: Rectangle {
                        color: "white"
                        opacity: 0.6
                        width: contributionLabel.width
                        height: contributionLabel.height
                            Label {
                                id: contributionLabel
                                font.pixelSize: Theme.fontSizeTiny
                                color: "black"
                                text: "(C) OpenStreetMap contributors"
                        }
                    }
                }
            }
        }
    }
}
