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
        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Backspace) {
            goBack()
            event.accepted = true
        }
    }

    AppBar {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.sh * 0.125
        anchors.leftMargin: root.sw * 0.125
        iconSource: moduleRoot.moduleIcon
        title: moduleRoot.moduleName
        subtitle: channelModel.length > 0 ? "Channels: " + channelModel.length : "Loading..."
    }

    ListView {
        id: itemList
        anchors.fill: parent
        anchors.topMargin: root.sh * 0.25
        anchors.leftMargin: root.sw * 0.115625
        anchors.rightMargin: root.sw * 0.115625
        anchors.bottomMargin: root.sh * 0.1
        model: itemsRoot.channelModel
        clip: true

        delegate: ItemDelegate {
            width: itemList.width
            height: root.sh * 0.08
            highlighted: ListView.isCurrentItem
            
            text: modelData.title

            background: Rectangle {
                color: highlighted ? "#33ffffff" : "transparent"
            }
        }

        Keys.onReturnPressed: {
            var selectedChannel = channelModel[currentIndex]
            if (selectedChannel && selectedChannel.url) {
                mpvController.loadAndPlay(selectedChannel.url, 0, 1, 1)
            }
        }
    }

    Connections {
        target: iptvBackend
        function onChannelsLoaded(channels) {
            itemsRoot.channelModel = channels
            
            var restore = navListState.currentIndex !== undefined ? navListState.currentIndex : 0
            itemList.currentIndex = Math.min(restore, Math.max(0, channels.length - 1))
            itemList.positionViewAtIndex(itemList.currentIndex, ListView.Contain)
        }
        function onErrorOccurred(error) {
            console.error("IPTV Error:", error)
        }
    }

    Component.onCompleted: {
        iptvBackend.fetchChannels()
    }
}