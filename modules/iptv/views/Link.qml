import QtQuick
import Components

FocusScope {
    id: linkRoot
    focus: true

    property var navParams: ({})
    property string customUrl: appCore.get_setting("com.240mp.iptv", "custom_url") || ""
    property string errorMsg: ""
    property var moduleInfo: appCore.get_module_info("com.240mp.iptv")

    signal replaceWith(string path, var params)
    signal goBack()

    function submit() {
        var url = serverInput.text.trim()
        if (!/^https?:\/\/[^\s\/?#]+(?:[\/?#][^\s]*)?$/i.test(url)) {
            errorMsg = "Please enter a valid HTTP/HTTPS playlist URL"
            return
        }
        errorMsg = ""
        appCore.save_setting("com.240mp.iptv", "custom_url", url)
        appCore.save_setting("com.240mp.iptv", "playlist_lang", "CUSTOM")
        if (navParams.settingsEditor)
            goBack()
        else
            replaceWith("Items.qml", {})
    }

    Component.onCompleted: serverInput.forceActiveFocus()

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
            goBack()
            event.accepted = true
        }
    }

    AppBar {
        iconSource: linkRoot.moduleInfo.icon || ""
        title: "IPTV"
        subtitle: "Custom playlist URL"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.sh * 0.125
        anchors.leftMargin: root.sw * 0.125
    }

    Column {
        anchors.centerIn: parent
        width: root.sw * 0.75
        spacing: root.sh * 0.025

        Text {
            text: "Enter M3U / M3U8 playlist URL:"
            color: root.secondaryColor
            font.family: root.globalFont
            font.capitalization: Font.AllUppercase
            font.pixelSize: root.sh * 0.0333333
        }

        Rectangle {
            width: parent.width
            height: root.sh * 0.0833333
            color: root.surfaceColor
            border.color: root.accentColor
            border.width: Math.max(1, root.sh * 0.0041667)

            TextInput {
                id: serverInput
                objectName: "playlistUrlInput"
                anchors.fill: parent
                anchors.margins: root.sh * 0.0166667
                text: linkRoot.customUrl
                color: root.primaryColor
                selectionColor: root.accentColor
                selectedTextColor: root.surfaceColor
                font.family: root.globalFont
                font.pixelSize: root.sh * 0.0375
                clip: true
                selectByMouse: true
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                Keys.onReturnPressed: linkRoot.submit()
                Keys.onEnterPressed: linkRoot.submit()
            }
        }

        Text {
            width: parent.width
            text: linkRoot.errorMsg
            visible: text !== ""
            color: root.accentColor
            font.family: root.globalFont
            font.pixelSize: root.sh * 0.0333333
            wrapMode: Text.Wrap
        }
    }

    Text {
        text: root.hints.back + ":CANCEL " + root.hints.select + ":SAVE"
        color: root.tertiaryColor
        font.family: root.globalFont
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: root.sh * 0.1041667
        anchors.leftMargin: root.sw * 0.125
        font.pixelSize: root.sh * 0.0333333
    }
}
