#ifndef HELPER_H
#define HELPER_H

#include <QDir>
#include <QStandardPaths>
#include <QProcess>
#include <QObject>

class Helper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString defaultMime READ defaultMime WRITE setDefaultMime NOTIFY defaultMimeChanged)

private:
    QString execMime(const QString &args);

public:
    explicit Helper(QObject *parent = 0);

signals:

    void defaultMimeChanged();

public slots:
    QString defaultMime();
    void setDefaultMime(QString desktopFile);
    void setRoot(QString appName);

};

#endif // HELPER_H
