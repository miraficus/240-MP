import QtQuick
import QtTest

Item {
    id: root
    width: 1280
    height: 720
    property real sw: width
    property real sh: height
    property string globalFont: "sans-serif"
    property color primaryColor: "white"
    property color secondaryColor: "lightgray"
    property color tertiaryColor: "gray"
    property color surfaceColor: "navy"
    property color accentColor: "cyan"
    property var hints: ({back: "ESC", select: "ENTER", navigate: "UP/DOWN", change: "LEFT/RIGHT"})

    QtObject {
        id: appCore
        property var values: ({})
        property var schema: []
        signal dynamicOptionsReady(string mid, string key, var items)
        signal moduleAuthStateChanged(string mid)
        function get_setting(mid, key) { return values[key] || "" }
        function save_setting(mid, key, value) { values[key] = value }
        function get_module_info(mid) { return {name: "IPTV", icon: ""} }
        function get_settings() { return {modules: {"com.240mp.iptv": values}} }
        function get_installed_modules() { return [{id: "com.240mp.iptv", name: "IPTV"}] }
        function get_module_settings_schema(mid) { return schema }
        function invoke_module_action(mid, slot) {}
    }
    QtObject {
        id: iptvBackend
        property string requested: ""
        signal channelsLoaded(var channels)
        signal errorOccurred(string message)
        function fetchChannels(source) { requested = source }
    }
    Loader { id: page; anchors.fill: parent }
    SignalSpy { id: navigation; signalName: "navigateTo" }
    SignalSpy { id: back; signalName: "goBack" }

    TestCase {
        name: "IPTVNavigation"
        when: windowShown
        function initTestCase() {
            var request = new XMLHttpRequest()
            request.open("GET", Qt.resolvedUrl("../../modules/iptv/manifest.json"), false)
            request.send()
            appCore.schema = JSON.parse(request.responseText).settings
        }
        function init() {
            navigation.target = null
            back.target = null
            page.source = ""
            appCore.values = {playlist_lang: "CUSTOM", custom_url: ""}
            iptvBackend.requested = ""
            navigation.clear()
            back.clear()
        }
        function load(path, params) {
            page.setSource(Qt.resolvedUrl(path), {navParams: params || {}})
            compare(page.status, Loader.Ready)
            verify(page.item !== null)
            wait(0)
        }
        function input() {
            var field = findChild(page.item, "playlistUrlInput")
            verify(field !== null)
            return field
        }
        function test_settings_opens_editor() {
            load("../../views/ModuleSettings.qml", {moduleId: "com.240mp.iptv"})
            navigation.target = page.item
            page.item.forceActiveFocus()
            keyClick(Qt.Key_Down)
            keyClick(Qt.Key_Down)
            keyClick(Qt.Key_Return)
            compare(navigation.count, 1)
            compare(navigation.signalArguments[0][0], "modules/iptv/views/Link.qml")
            compare(navigation.signalArguments[0][1].settingsEditor, true)
        }
        function test_empty_custom_opens_editor_and_save_loads_channels() {
            load("../../modules/iptv/views/Root.qml")
            var field = input()
            compare(iptvBackend.requested, "")
            field.text = "  https://example.org/MyList.m3u?Token=AbC  "
            field.forceActiveFocus()
            keyClick(Qt.Key_Return)
            tryCompare(iptvBackend, "requested", "https://example.org/MyList.m3u?Token=AbC")
            compare(appCore.values.custom_url, iptvBackend.requested)
            // Saving replaces the editor: Back exits the module, not an editor loop.
            back.target = page.item
            keyClick(Qt.Key_Escape)
            compare(back.count, 1)
        }
        function test_saved_custom_loads_directly() {
            appCore.values.custom_url = "https://example.org/saved.m3u"
            load("../../modules/iptv/views/Root.qml")
            compare(iptvBackend.requested, appCore.values.custom_url)
        }
        function test_settings_editor_save_returns() {
            appCore.values.playlist_lang = "CZ"
            load("../../modules/iptv/views/Link.qml", {settingsEditor: true})
            back.target = page.item
            input().text = "https://example.org/new.m3u"
            keyClick(Qt.Key_Enter)
            compare(back.count, 1)
            compare(appCore.values.playlist_lang, "CUSTOM")
            compare(appCore.values.custom_url, "https://example.org/new.m3u")
        }
        function test_invalid_url_does_not_save() {
            load("../../modules/iptv/views/Link.qml", {settingsEditor: true})
            back.target = page.item
            input().text = "not a URL"
            keyClick(Qt.Key_Return)
            compare(back.count, 0)
            compare(appCore.values.custom_url, "")
            verify(page.item.errorMsg !== "")
        }
        function test_backspace_edits_and_escape_cancels() {
            appCore.values.custom_url = "https://example.org/ab"
            load("../../modules/iptv/views/Link.qml", {settingsEditor: true})
            back.target = page.item
            var field = input()
            field.cursorPosition = field.text.length
            field.forceActiveFocus()
            keyClick(Qt.Key_Backspace)
            compare(field.text, "https://example.org/a")
            compare(back.count, 0)
            keyClick(Qt.Key_Escape)
            compare(back.count, 1)
            compare(appCore.values.custom_url, "https://example.org/ab")
        }
    }
}
