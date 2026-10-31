import QtQuick
import QtTest
Item {
    id: root
    width: 1280; height: 720
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
        property var values: ({enabled: true})
        property var schema: [{key: "enabled", label: "Enabled", type: "toggle", default: "ON"}]
        signal dynamicOptionsReady(string mid, string key, var options)
        signal moduleAuthStateChanged(string mid)
        function get_settings() { return {modules: {test: values}} }
        function get_installed_modules() { return [{id: "test", name: "Test"}] }
        function get_module_settings_schema(id) { return schema }
        function save_setting(id, key, value) { values[key] = value }
    }
    Loader { id: page; anchors.fill: parent }
    TestCase {
        name: "TranslatedSettings"
        when: windowShown
        function test_toggle_uses_boolean_not_translated_label() {
            page.setSource(Qt.resolvedUrl("../../views/ModuleSettings.qml"), {navParams: {moduleId: "test"}})
            compare(page.status, Loader.Ready)
            compare(page.item.currentDisplayValue(appCore.schema[0]), "ZAP")
            page.item.cycleValue(0, 1)
            compare(appCore.values.enabled, false)
            compare(page.item.currentDisplayValue(appCore.schema[0]), "VYP")
            page.item.cycleValue(0, 1)
            compare(appCore.values.enabled, true)
        }
    }
}
