import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property int cfg_lang1: Plasmoid.configuration.firstLanguage
    readonly property int cfg_lang2: Plasmoid.configuration.secondLanguage
    readonly property int cfg_lang3: Plasmoid.configuration.thirdLanguage
    property int lastProcessedIndex: 0

    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        Layout.preferredWidth: lyricsLabel.implicitWidth
        Layout.preferredHeight: lyricsLabel.implicitHeight
        Label {
            id: lyricsLabel
            text: ""
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font: plasmoid.configuration.lyricsFont || Kirigami.Theme.defaultFont
            color: plasmoid.configuration.lyricsColor || Kirigami.Theme.textColor
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
            // Filter SSE output into lyrics and lyric names, the latter is output when switching songs
            xhr.open("GET", "http://127.0.0.1:23330/subscribe-player-status?filter=lyricLineAllText,name", true);
            xhr.setRequestHeader("Accept", "text/event-stream");

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.LOADING) {
                    processEvent(xhr.responseText);
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

        function processEvent(responseText) {
            // Process the received data
            var newText = responseText.substring(lastProcessedIndex);
            var events = newText.split("\n\n");

            // Parse and handle each new event
            // the reason i < events.length - 1 is because the last event may be "" 
            // if the server hasn't finished sending it yet.
            for (var i = 0; i < events.length - 1; i++) {
                var event = events[i];
                // Check if songs switched
                // to avoid the bug displaying lyrics of last song when switching to pure songs
                if (event.startsWith("event: name")) {
                    lyricsLabel.text = "";
                } else {
                    displayLirics(event);
                }
            }

            lastProcessedIndex = responseText.lastIndexOf("\n\n") + 2;
        }

        function displayLirics(event) {
            // API example
            // event: lyricLineAllText
            // data: "可愛い子可愛い子\n可爱的孩子啊\nka wa i i ko ka wa i i ko"
            //
            // event: lyricLineAllText
            // data: "月や星の言葉を\n安眠的时候\ntsu ki ya ho shi no ko to ba wo"
            //
            // event: lyricLineAllText
            // data: "眠っている間に聞きなさい\n聆听月亮和星星的呢喃\nne mu tte i ru a i da ni ki ki na sa i"
            //
            // plasmoid.configuration.[first|second|third]Language
            // Original: 0
            // Translation: 1
            // Romanization: 2
            // None: 3
            var data = event.split("\n")[1];
            var allLyrics = data.substring(7, data.length - 1).split("\\n");
            var lyrics = "";
            if (allLyrics[cfg_lang1]) {
              lyrics = allLyrics[cfg_lang1] + " "
            }
            if (allLyrics[cfg_lang2]) {
              lyrics = lyrics + allLyrics[cfg_lang2] + " "
            }
            if (allLyrics[cfg_lang3]) {
              lyrics = lyrics + allLyrics[cfg_lang3]
            }
            lyricsLabel.text = lyrics.trim();
        }
    }
}
