#include "LanguageManager.h"
#include <QCoreApplication>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocale>
#include <QVariantMap>

QStringList LanguageManager::supportedLanguages() { return {QStringLiteral("en"), QStringLiteral("cs")}; }

QString LanguageManager::resolveLanguage(const QString &preference, const QStringList &systemLanguages) {
    if (preference != QLatin1String("auto") && !preference.isEmpty())
        return supportedLanguages().contains(preference) ? preference : QStringLiteral("en");
    for (QString locale : systemLanguages) {
        locale.replace('-', '_');
        const QString language = locale.section('_', 0, 0).toLower();
        if (supportedLanguages().contains(language)) return language;
    }
    return QStringLiteral("en");
}

LanguageManager::LanguageManager(const QString &dataRoot, QObject *parent)
    : QObject(parent), m_language(QStringLiteral("auto")) {
    QFile file(dataRoot + "/config.json");
    if (file.open(QIODevice::ReadOnly)) {
        const QString saved = QJsonDocument::fromJson(file.readAll()).object()
                                  .value("app").toObject().value("language").toString("auto");
        if (saved == QLatin1String("auto") || supportedLanguages().contains(saved)) m_language = saved;
    }
    m_effectiveLanguage = resolveLanguage(m_language, QLocale::system().uiLanguages());
    if (m_effectiveLanguage != QLatin1String("en") &&
        m_translator.load(":/i18n/240mp_" + m_effectiveLanguage + ".qm"))
        QCoreApplication::installTranslator(&m_translator);
}

QVariantList LanguageManager::languages() const {
    // Endonyms make the picker usable even after choosing an unfamiliar language.
    return {QVariantMap{{"id", "auto"}, {"label", tr("System language")}},
            QVariantMap{{"id", "en"}, {"label", QStringLiteral("English")}},
            QVariantMap{{"id", "cs"}, {"label", QStringLiteral("Čeština")}}};
}
