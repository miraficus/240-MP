#include <QtTest>
#include <QTemporaryDir>
#include <QFile>
#include "../../src/i18n/LanguageManager.h"
#include "../../src/AppCore.h"

class I18nTest : public QObject {
    Q_OBJECT
private slots:
    void localeSelection() {
        QCOMPARE(LanguageManager::resolveLanguage("auto", {"cs-CZ", "en"}), QString("cs"));
        QCOMPARE(LanguageManager::resolveLanguage("auto", {"de-DE", "en-US"}), QString("en"));
        QCOMPARE(LanguageManager::resolveLanguage("auto", {"fr"}), QString("en"));
        QCOMPARE(LanguageManager::resolveLanguage("en", {"cs-CZ"}), QString("en"));
        QCOMPARE(LanguageManager::resolveLanguage("invalid", {"cs-CZ"}), QString("en"));
    }
    void loadsCatalogAndPreservesSettings() {
        QTemporaryDir data;
        QFile config(data.filePath("config.json"));
        QVERIFY(config.open(QIODevice::WriteOnly));
        config.write(R"({"app":{"language":"cs","color_scheme":"Video 1"},"modules":{}})");
        config.close();
        LanguageManager manager(data.path());
        QCOMPARE(manager.language(), QString("cs"));
        QCOMPARE(manager.effectiveLanguage(), QString("cs"));
        QCOMPARE(manager.languages().first().toMap()["label"].toString(), QString::fromUtf8("Systémový jazyk"));
        QCOMPARE(QCoreApplication::translate("Missing", "English fallback"), QString("English fallback"));
        AppCore core(SOURCE_ROOT, data.path());
        const QString id = "com.240mp.local_files";
        QCOMPARE(core.get_module_info(id).toMap()["name"].toString(), QString::fromUtf8("Místní soubory"));
        const auto schema = core.get_module_settings_schema(id).toList();
        QCOMPARE(schema.first().toMap()["label"].toString(), QString::fromUtf8("POVOLENO"));
        QCOMPARE(schema.first().toMap()["key"].toString(), QString("enabled"));
        QCOMPARE(schema.first().toMap()["default"].toString(), QString("ON"));
        core.save_setting(id, "enabled", true);
        QCOMPARE(core.get_setting(id, "enabled").toBool(), true);
        QCOMPARE(core.get_setting("", "color_scheme").toString(), QString("Video 1"));
    }
    void invalidConfigUsesAutomaticLanguage() {
        QTemporaryDir data;
        QFile config(data.filePath("config.json"));
        QVERIFY(config.open(QIODevice::WriteOnly));
        config.write("not json"); config.close();
        LanguageManager manager(data.path());
        QCOMPARE(manager.language(), QString("auto"));
    }
};
QTEST_GUILESS_MAIN(I18nTest)
#include "tst_backend.moc"
