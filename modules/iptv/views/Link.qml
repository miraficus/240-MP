import QtQuick
import Components

FocusScope {
    focus: true
    id: linkRoot

    property var navParams: ({})
    signal navigateTo(string path, var params, var listState)
    signal replaceWith(string path, var params)
    signal goBack()

    property string customUrl: appCore.get_setting("com.240mp.iptv", "custom_url") || ""
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
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            linkRoot.submit()
            event.accepted = true
        }
    }

    function submit() {
        if (customUrl === "" || (!customUrl.startsWith("http://") && !customUrl.startsWith("https://"))) {
            errorMsg = "PLEASE ENTER A VALID HTTP/HTTPS URL"
            return
        }
        errorMsg = ""
        // Save URL and enforce CUSTOM playlist selection
        appCore.save_setting("com.240mp.iptv", "custom_url", linkRoot.customUrl)
        appCore.save_setting("com.240mp.iptv", "playlist_lang", "CUSTOM")
        
        // Go back to channel list
        goBack()
    }

    AppBar {
        iconSource: moduleRoot.moduleIcon
        title: moduleRoot.moduleName
        subtitle: "Custom IPTV Playlist"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.sh * 0.125
        anchors.leftMargin: root.sw * 0.125
    }

    Column {
        anchors.centerIn: parent
        spacing: root.sh * 0.0333333

        Column {
            spacing: root.sh * 0.0166667
            width: root.sw * 0.6
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "M3U PLAYLIST URL"
                color: root.secondaryColor
                font.family: root.globalFont
                font.pixelSize: root.sh * 0.0291667
            }

            Rectangle {
                width: parent.width
                height: root.sh * 0.075
                color: root.surfaceColor
                border.color: root.accentColor
                border.width: root.sh * 0.003125

                TextInput {
                    id: serverInput
                    anchors.fill: parent
                    anchors.margins: root.sh * 0.0166667
                    text: linkRoot.customUrl
                    color: root.primaryColor
                    font.family: root.globalFont
                    font.pixelSize: root.sh * 0.0333333
                    clip: true
                    
                    onTextChanged: { linkRoot.customUrl = text }
                }
            }
        }

        // Action Button
        Rectangle {
            width: root.sw * 0.2
            height: root.sh * 0.0583333
            color: root.accentColor
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                anchors.centerIn: parent
                text: "SAVE & LOAD"
                color: root.surfaceColor
                font.family: root.globalFont
                font.pixelSize: root.sh * 0.0333333
            }
        }

        Text {
            visible: errorMsg !== ""
            text: errorMsg
            color: root.accentColor
            font.family: root.globalFont
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.sw * 0.6
            wrapMode: Text.WordWrap
            font.pixelSize: root.sh * 0.0333333
        }
    }

    // Footer Hints
    Text {
        text: root.hints.back + ":BACK " + root.hints.select + ":SAVE"
        color: root.tertiaryColor
        font.family: root.globalFont
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: root.sh * 0.1041667
        anchors.leftMargin: root.sw * 0.125
        font.pixelSize: root.sh * 0.0333333
    }
}