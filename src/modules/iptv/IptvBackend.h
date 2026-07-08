#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>
#include <QVariantMap>

class IptvBackend : public QObject {
    Q_OBJECT
public:
    explicit IptvBackend(QObject *parent = nullptr);

    Q_INVOKABLE void fetchChannels(const QString &langCode);
    
    Q_INVOKABLE void get_playlist_languages();

signals:
    void channelsLoaded(const QVariantList &channels);
    void errorOccurred(const QString &error);
    
    void dynamicOptionsReady(const QString &key, const QVariant &options);

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_networkManager;
};