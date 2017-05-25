#include "helper.h"
#include <QGuiApplication>

Helper::Helper(QObject *parent) : QObject(parent)
{

}

QString Helper::defaultMime()
{
    return this->execMime(QString("query default text/plain"));
}

void Helper::setDefaultMime(QString appName)
{
    QString desktop = appName + ".desktop";
    QDir localapplicationsdir = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    localapplicationsdir.cd("applications");
    if(!localapplicationsdir.exists("defaults.list")) {
        QProcess link;
        link.start("ln -sf " + localapplicationsdir.absoluteFilePath("mimeapps.list") +" " + localapplicationsdir.absoluteFilePath("defaults.list"));
        link.waitForFinished();
    }
    this->execMime(QString("default " + desktop + " text/plain"));
    emit defaultMimeChanged();
}

void Helper::setRoot(QString appName)
{
  QProcess::startDetached("/usr/bin/"+appName+"-root");
}

QString Helper::execMime(const QString &args)
{
    QProcess mime;
    mime.start(QString("xdg-mime " + args));
    mime.waitForFinished();
    return QString::fromUtf8(mime.readAllStandardOutput()).simplified();
}

