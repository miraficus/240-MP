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

    Q_INVOKABLE void fetchChannels();

signals:
    void channelsLoaded(const QVariantList &channels);
    void errorOccurred(const QString &error);

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *m_networkManager;
    const QString m_playlistUrl = "https://raw.githubusercontent.com/iptv-org/iptv/master/streams/cz.m3u";
};