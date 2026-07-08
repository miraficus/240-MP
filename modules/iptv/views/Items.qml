import QtQuick
import QtQuick.Controls
import Components

FocusScope {
    id: itemsRoot

    property var navParams: ({})
    property var navListState: navParams.navListState || ({})
    property var channelModel: []

    signal navigateTo(string path, var params, var listState)
    signal goBack()

    focus: true
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace || event.key === Qt.Key_Back) {
            goBack()
            event.accepted = true
        }
    }

    // Header
    AppBar {
        id: appBar
        iconSource: moduleRoot.moduleIcon
        title: moduleRoot.moduleName
        subtitle: channelModel.length > 0 ? "Channels: " + channelModel.length : "Loading..."
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.sh * 0.125
        anchors.leftMargin: root.sw * 0.125
    }

    // Empty state
    Column {
        anchors.centerIn: parent
        spacing: root.sh * 0.0333333
        visible: itemList.count === 0
        Text {
            text: "No channels found"
            color: root.secondaryColor
            font.family: root.globalFont
            font.capitalization: Font.AllUppercase
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: root.sh * 0.05
        }
    }

    // IPTV List
    ListView {
        id: itemList
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.sh * 0.25
        anchors.leftMargin: root.sw * 0.115625
        width: root.sw * 0.76875
        height: root.sh * 0.525
        keyNavigationEnabled: true
        clip: true
        focus: true

        // Open Player.qml with Enter/Return
        Keys.onReturnPressed: {
            var selectedChannel = itemsRoot.channelModel[currentIndex]
            if (selectedChannel && selectedChannel.url) {
                navigateTo("Player.qml",
                    { item: selectedChannel },
                    { currentIndex: itemList.currentIndex })
            }
        }

        delegate: Item {
            width: itemList.width
            height: root.sh * 0.0583333

            Item {
                id: textClip
                width: Math.min(rowText.implicitWidth, itemList.width)
                height: parent.height
                clip: true

                Rectangle {
                    color: root.accentColor
                    anchors.fill: rowText
                    visible: itemList.currentIndex === index
                }

                Text {
                    id: rowText
                    text: modelData.title
                    color: itemList.currentIndex === index ? root.surfaceColor : root.primaryColor
                    font.family: root.globalFont
                    font.capitalization: Font.AllUppercase
                    anchors.verticalCenter: parent.verticalCenter
                    x: 0
                    topPadding: root.sh * 0.0041667
                    leftPadding: root.sw * 0.009375
                    rightPadding: root.sw * 0.009375
                    bottomPadding: root.sh * 0.00625
                    font.pixelSize: root.sh * 0.05
                }

                SequentialAnimation {
                    running: (itemList.currentIndex === index) && (rowText.implicitWidth > textClip.width)
                    loops: Animation.Infinite
                    onRunningChanged: if (!running) rowText.x = 0
                    PauseAnimation { duration: 1500 }
                    NumberAnimation {
                        target: rowText; property: "x"
                        to: textClip.width - rowText.implicitWidth
                        duration: Math.abs(to) * 20
                    }
                    PauseAnimation { duration: 2000 }
                    PropertyAction { target: rowText; property: "x"; value: 0 }
                }
            }
        }
    }

    Connections {
        target: iptvBackend
        function onChannelsLoaded(channels) {
            itemsRoot.channelModel = channels
            itemList.model = channels
            var restore = navListState.currentIndex !== undefined ? navListState.currentIndex : 0
            itemList.currentIndex = Math.min(restore, Math.max(0, channels.length - 1))
            itemList.positionViewAtIndex(itemList.currentIndex, ListView.Contain)
        }
    }

    Component.onCompleted: {
        var lang = appCore.get_setting(moduleRoot.moduleId, "playlist_lang") || "ALL"

        iptvBackend.fetchChannels(lang)
        itemList.forceActiveFocus()
    }

    // Footer
    Text {
        id: footer
        text: root.hints.back + ":BACK " + root.hints.navigate + ":NAVIGATE " + root.hints.select + ":SELECT"
        color: root.tertiaryColor
        font.family: root.globalFont
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: root.sh * 0.1041667
        anchors.leftMargin: root.sw * 0.125
        font.pixelSize: root.sh * 0.0333333
    }
}