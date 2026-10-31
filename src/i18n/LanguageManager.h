#pragma once
#include <QObject>
#include <QStringList>
#include <QTranslator>
#include <QVariantList>

// UI language only: never change locale-dependent protocol/config values.
// Selection is persisted by AppCore and applied on the next application start.
class LanguageManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString language READ language CONSTANT)
    Q_PROPERTY(QString effectiveLanguage READ effectiveLanguage CONSTANT)
    Q_PROPERTY(QVariantList languages READ languages CONSTANT)
public:
    explicit LanguageManager(const QString &dataRoot, QObject *parent = nullptr);
    QString language() const { return m_language; }
    QString effectiveLanguage() const { return m_effectiveLanguage; }
    QVariantList languages() const;
    static QStringList supportedLanguages();
    static QString resolveLanguage(const QString &preference, const QStringList &systemLanguages);
private:
    QString m_language;
    QString m_effectiveLanguage;
    QTranslator m_translator;
};
