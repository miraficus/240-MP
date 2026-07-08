import QtQuick
import QtQuick.Controls
import Components

FocusScope {
    id: linkRoot
    anchors.fill: parent
    focus: true

    property var navParams: ({})
    signal navigateTo(string path, var params, var listState)
    signal goBack()

    property string customUrl: appCore ? (appCore.get_setting("com.240mp.iptv", "custom_url") || "") : ""
    property string errorMsg: ""

    Component.onCompleted: {
        serverInput.forceActiveFocus()
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace || event.key === Qt.Key_Back) {
            goBack()
            event.accepted = true
            return
        }
    }

    function submit() {
        var trimmedUrl = customUrl.trim()
        if (trimmedUrl === "" || (!trimmedUrl.toLowerCase().startsWith("http://") && !trimmedUrl.toLowerCase().startsWith("https://"))) {
            errorMsg = "PLEASE ENTER A VALID HTTP/HTTPS URL"
            return
        }
        errorMsg = ""
        
        if (appCore) {
            appCore.save_setting("com.240mp.iptv", "custom_url", trimmedUrl)
            appCore.save_setting("com.240mp.iptv", "playlist_lang", "CUSTOM")
        }
        
        goBack()
    }

    // Header matching Items.qml structure
    AppBar {
        id: appBar
        iconSource: _moduleInfo ? _moduleInfo.icon : ""
        title: _moduleInfo ? _moduleInfo.name : "IPTV"
        subtitle: "Custom M3U Playlist URL"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: parent.height * 0.125
        anchors.leftMargin: parent.width * 0.125
    }

    Column {
        anchors.centerIn: parent
        spacing: parent.height * 0.033

        Column {
            spacing: parent.height * 0.016
            width: 400

            Text {
                text: "ENTER PLAYLIST URL:"
                color: "#FFFFFF"
                font.pixelSize: 16
            }

            Rectangle {
                width: parent.width
                height: 40
                color: "#222222"
                border.color: "#FFFFFF"
                border.width: 2

                TextInput {
                    id: serverInput
                    anchors.fill: parent
                    anchors.margins: 8
                    text: linkRoot.customUrl
                    color: "#FFFFFF"
                    font.pixelSize: 18
                    clip: true
                    focus: true
                    
                    onTextChanged: { linkRoot.customUrl = text }

                    Keys.onReturnPressed: {
                        linkRoot.submit()
                    }
                }
            }
        }

        // Error message text block
        Text {
            visible: errorMsg !== ""
            text: errorMsg
            color: "#FF0000"
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // Footer matching Items.qml structure
    Text {
        text: "BACK: CANCEL / ENTER: SAVE & LOAD"
        color: "#888888"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: parent.height * 0.1
        anchors.leftMargin: parent.width * 0.125
        font.pixelSize: 16
    }
}