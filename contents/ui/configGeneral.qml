pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs as QtDialogs

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: generalPage

    property alias cfg_lyricsFont: fontDialog.fontChosen
    property alias cfg_lyricsColor: colorDialog.colorChosen
    property alias cfg_firstLanguage: firstLanguage.currentIndex
    property alias cfg_secondLanguage: secondLanguage.currentIndex
    property alias cfg_thirdLanguage: thirdLanguage.currentIndex

    Kirigami.FormLayout {
        // TODO Translation

        QQC2.Button {
            id: fontButton
            Kirigami.FormData.label: i18n("Font:")
            text: i18nc("@action:button", "%1pt %2", fontDialog.fontChosen.pointSize, fontDialog.fontChosen.family)
            onClicked: {
                fontDialog.selectedFont = fontDialog.fontChosen
                fontDialog.open()
            }
        }

        QtDialogs.FontDialog {
            id: fontDialog
            title: i18nc("@title:window", "Choose a Font")
            modality: Qt.WindowModal
            parentWindow: generalPage.Window.window

            // create fontChosen other than use selectedFont directly
            // to set cfg_lyricsFont only when accepted the selection.
            property font fontChosen: Qt.font()

            onAccepted: {
                fontChosen = selectedFont
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Color:")

            Rectangle {
                height: 20
                width: 20
                radius: mouseArea.containsMouse ? 10 : 5
                color: colorDialog.colorChosen
                border.color: "black"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: colorDialog.open()
            }

            QtDialogs.ColorDialog {
                id: colorDialog
                title: "Set lyrics color"

                // create colorChosen other than use selectedColor directly
                // to set cfg_lyricsColor only when accepted the selection.
                property string colorChosen: ""

                onAccepted: {
                  colorChosen = selectedColor
                }
            }

        }

        RowLayout {
            Kirigami.FormData.label: i18n("Lirics format:")
            spacing: Kirigami.Units.smallSpacing

            QQC2.ComboBox {
                id: firstLanguage
                model: [
                  i18n("None"),
                  i18n("Original"),
                  i18n("Translation"),
                  i18n("Romanization"),
                ]
                onActivated: cfg_firstLanguage = currentIndex
            }

            QQC2.ComboBox {
                id: secondLanguage
                model: [
                  i18n("None"),
                  i18n("Original"),
                  i18n("Translation"),
                  i18n("Romanization"),
                ]
                onActivated: cfg_secondLanguage = currentIndex
            }

            QQC2.ComboBox {
                id: thirdLanguage
                model: [
                  i18n("None"),
                  i18n("Original"),
                  i18n("Translation"),
                  i18n("Romanization"),
                ]
                onActivated: cfg_thirdLanguage = currentIndex
            }
        }
    }
}
