#include <QtQuickTest/quicktest.h>
#include <QTemporaryDir>
#include <QFile>
#include "../../src/i18n/LanguageManager.h"
class Setup : public QObject {
    Q_OBJECT
    QTemporaryDir data;
public slots:
    void applicationAvailable() {
        QFile config(data.filePath("config.json"));
        if (config.open(QIODevice::WriteOnly)) {
            config.write(R"({"app":{"language":"cs"}})"); config.close();
        }
        new LanguageManager(data.path(), this);
    }
};
QUICK_TEST_MAIN_WITH_SETUP(i18n, Setup)
#include "quicktest.moc"
