import QtQuick
import Components

FocusScope {
    id: playerRoot

    property var navParams: ({})
    signal goBack()

    property var    item:            navParams.item || ({})
    property string videoUrl:        item.url || ""
    property string videoTitle:      item.title || "IPTV STREAM"

    property bool   playbackStarted: false
    property string errorMessage:    ""

    focus: true

    function doPlay() {
        mpvController.loadAndPlay(
            videoUrl, 
            0.0, 
            0, 
            -2, 
            [], 
            [], 
            false, 
            -1, 
            0.0, 
            "", 
            false, 
            "", 
            false, 
            ["--cache=yes", "--demuxer-max-bytes=50MiB", "--hr-seek=yes"],
            0, 
            false
        )
    }

    Timer {
        id: startTimer
        interval: 50
        repeat: false
        onTriggered: doPlay()
    }

    Keys.onPressed: function(event) {
        if (errorMessage !== "") {
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace || event.key === Qt.Key_Back) {
                goBack()
                event.accepted = true
            }
        } else {
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Back) {
                mpvController.sendKey("ESC")
                event.accepted = true
            } else if (event.key === Qt.Key_Backspace) {
                mpvController.sendKey("BS")
                event.accepted = true
            } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                mpvController.sendKey("SPACE")
                event.accepted = true
            }
        }
    }

    Connections {
        target: mpvController

        function onPositionChanged(ms) {
            playerRoot.playbackStarted = true
        }

        function onPlaybackEnded(finalPositionMs, finalDurationMs, reason) {
            if (reason === "failed" && !playbackStarted) {
                playerRoot.errorMessage = "PLAYBACK FAILED\n\nCANNOT CONNECT TO THE STREAM"
                return
            }
            goBack()
        }
    }

    Component.onCompleted: {
        if (videoUrl === "") {
            goBack()
            return
        }
        startTimer.restart()
    }

    Rectangle {
        anchors.fill: parent
        color: "black"

        Text {
            text: "LOADING..."
            color: "white"
            font.family: root.globalFont
            font.capitalization: Font.AllUppercase
            anchors.centerIn: parent
            font.pixelSize: root.sh * 0.05 // 24px
            visible: !playbackStarted && errorMessage === ""
        }

        Column {
            anchors.centerIn: parent
            spacing: root.sh * 0.05
            visible: errorMessage !== ""

            Text {
                text: errorMessage
                color: "white"
                font.family: root.globalFont
                font.capitalization: Font.AllUppercase
                width: root.sw * 0.5625
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: root.sh * 0.0375 // 18px
            }
            Text {
                text: root.hints.back + ":BACK"
                color: root.tertiaryColor
                font.family: root.globalFont
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: root.sh * 0.0333333 // 16px
            }
        }
    }
}