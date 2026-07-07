#include "IptvBackend.h"
#include <QNetworkRequest>
#include <QUrl>

IptvBackend::IptvBackend(QObject *parent) : QObject(parent) {
    m_networkManager = new QNetworkAccessManager(this);
}

void IptvBackend::fetchChannels() {
    QNetworkRequest request((QUrl(m_playlistUrl)));
    QNetworkReply *reply = m_networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() { this->onReplyFinished(reply); });
}

void IptvBackend::onReplyFinished(QNetworkReply *reply) {
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        emit errorOccurred(reply->errorString());
        return;
    }

    QString data = QString::fromUtf8(reply->readAll());
    QStringList lines = data.split('\n');
    QVariantList channels;

    QString currentTitle = "";

    for (const QString &line : lines) {
        QString trimmed = line.trimmed();
        if (trimmed.isEmpty()) continue;

        if (trimmed.startsWith("#EXTINF:")) {
            // Extrahujeme název za poslední čárkou
            int lastComma = trimmed.lastIndexOf(',');
            if (lastComma != -1) {
                currentTitle = trimmed.mid(lastComma + 1).trimmed();
            } else {
                currentTitle = "Unknown Channel";
            }
        } else if (!trimmed.startsWith('#')) {
            if (!currentTitle.isEmpty()) {
                QVariantMap channel;
                channel["title"] = currentTitle;
                channel["url"] = trimmed;
                channels.append(channel);
                currentTitle = ""; 
            }
        }
    }

    emit channelsLoaded(channels);
}