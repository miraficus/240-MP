#include <QtTest>
#include <QTcpServer>
#include <QTcpSocket>
#include "../../src/modules/iptv/IptvBackend.h"

class BackendTest : public QObject {
    Q_OBJECT
private slots:
    void customUrlPreservesPathAndQuery() {
        QTcpServer server;
        QVERIFY(server.listen(QHostAddress::LocalHost));
        QByteArray request;
        connect(&server, &QTcpServer::newConnection, this, [&] {
            auto *socket = server.nextPendingConnection();
            connect(socket, &QTcpSocket::readyRead, this, [&, socket] {
                request += socket->readAll();
                if (!request.contains("\r\n\r\n")) return;
                const QByteArray body = "#EXTM3U\n#EXTINF:-1,Test channel\nhttps://example.org/live.m3u8\n";
                socket->write("HTTP/1.1 200 OK\r\nContent-Length: " + QByteArray::number(body.size()) + "\r\nConnection: close\r\n\r\n" + body);
                socket->disconnectFromHost();
            });
        });
        IptvBackend backend;
        QSignalSpy loaded(&backend, &IptvBackend::channelsLoaded);
        QSignalSpy failed(&backend, &IptvBackend::errorOccurred);
        backend.fetchChannels(QString("  http://127.0.0.1:%1/MyList.m3u?Token=AbC  ").arg(server.serverPort()));
        QVERIFY(loaded.wait(5000));
        QCOMPARE(failed.count(), 0);
        QVERIFY(request.startsWith("GET /MyList.m3u?Token=AbC HTTP/1.1"));
        const auto channels = loaded.first().first().toList();
        QCOMPARE(channels.size(), 1);
        QCOMPARE(channels.first().toMap().value("title").toString(), QString("Test channel"));
        QCOMPARE(channels.first().toMap().value("url").toString(), QString("https://example.org/live.m3u8"));
    }
    void invalidSourcesFailWithoutLoadingWorldPlaylist() {
        IptvBackend backend;
        QSignalSpy failed(&backend, &IptvBackend::errorOccurred);
        backend.fetchChannels("CUSTOM");
        backend.fetchChannels("https://");
        QCOMPARE(failed.count(), 2);
    }
};
QTEST_GUILESS_MAIN(BackendTest)
#include "tst_backend.moc"
