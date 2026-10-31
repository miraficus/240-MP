import QtQuick

FocusScope {
    id: moduleRoot

    signal goBack()

    property var navParams: ({})

    property string moduleId: "com.240mp.iptv"

    property var _moduleInfo: appCore ? appCore.get_module_info(moduleId) : ({})
    property string moduleName: _moduleInfo.name || ""
    property string moduleIcon: _moduleInfo.icon || ""

    property var navStack: []
    property var currentParams: ({})

    function navigateTo(viewPath, params, fromState) {
        var resolved = Qt.resolvedUrl(viewPath)
        navStack.push({ source: internalLoader.source, params: currentParams, listState: fromState || {} })
        currentParams = params || {}
        internalLoader.setSource(resolved, { "navParams": params || {} })
    }

    function replaceWith(viewPath, params) {
        navStack = []
        currentParams = params || {}
        internalLoader.setSource(Qt.resolvedUrl(viewPath), { "navParams": currentParams })
    }

    function navigateBack() {
        if (navStack.length === 0) {
            moduleRoot.goBack()
            return
        }
        var prev = navStack.pop()
        if (!prev.source || prev.source.toString() === "") {
            moduleRoot.goBack()
            return
        }
        var restored = Object.assign({}, prev.params)
        restored.navListState = prev.listState || {}
        currentParams = restored
        internalLoader.setSource(prev.source, { "navParams": restored })
    }

    Loader {
        id: internalLoader
        anchors.fill: parent
        focus: true
        onLoaded: { if (item) item.forceActiveFocus() }

        Connections {
            target: internalLoader.item
            ignoreUnknownSignals: true
            function onNavigateTo(path, params, listState) { 
                console.log("IPTV ROUTER - Received navigateTo signal for path:", path)
                moduleRoot.navigateTo(path, params, listState) 
            }
            function onReplaceWith(path, params) { moduleRoot.replaceWith(path, params) }
            function onGoBack() { moduleRoot.navigateBack() }
        }
    }

    Component.onCompleted: {
        var custom = appCore.get_setting(moduleId, "playlist_lang") === "CUSTOM"
        var url = appCore.get_setting(moduleId, "custom_url") || ""
        replaceWith(custom && url.trim() === "" ? "Link.qml" : "Items.qml", {})
    }
}
