import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        Layout.preferredWidth: lyricsLabel.implicitWidth
        Layout.preferredHeight: lyricsLabel.implicitHeight
        Label {
            id: lyricsLabel
            text: "Waiting for messages..."
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Timer {
            id: reconnectTimer
            interval: 5000 // 5 seconds
            repeat: false
            onTriggered: startSSE()
        }

        Component.onCompleted: {
            startSSE();
        }

        function startSSE() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "http://localhost:23330/subscribe-player-status", true);
            xhr.setRequestHeader("Accept", "text/event-stream");

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.LOADING) {
                    // Process the received data
                    var responseText = xhr.responseText;
                    var events = responseText.split("\n\n");

                    // Parse the last event
                    // -2 instead of -1
                    // as split() may leave an empty string at the end of the array
                    // if the last event hasn't been completely received.
                    if (events.length > 1) {
                        var lastEvent = events[events.length - 2];
                        if (lastEvent && lastEvent.startsWith("event: lyricLineText")) {
                            var data = lastEvent.split("\n")[1].split(": ")[1];
                            lyricsLabel.text = data.replace(/\"/g, "");
                        }
                    }
                } else if (xhr.readyState === XMLHttpRequest.DONE) {
                    // Reconnect if the connection is closed
                    reconnectTimer.start();
                }
            };

            xhr.onerror = function() {
                lyricsLabel.text = "";
                reconnectTimer.start();
            };

            xhr.send();
        }
    }
}
