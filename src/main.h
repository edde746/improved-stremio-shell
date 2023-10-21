#include <QtQml/QQmlApplicationEngine>
#include <QtWebEngine/qtwebengineglobal.h>
#include <QtCore/QSysInfo>
#include <QtWidgets/QApplication>
#include <QtQml/QQmlEngine>
#include <QtCore/QStandardPaths>
#include <QtWidgets/QSystemTrayIcon>
#include <QtCore/QEvent>
#include <QtGui/QFileOpenEvent>
#include <QQmlContext>

class MainApp : public QApplication
{
    Q_OBJECT

  public: 
    MainApp(int &argc, char **argv, bool unique) : QApplication(argc, argv, unique) {};

    protected:
    bool event (QEvent *event) 
    {
      // The system requested us to open a file
      if (event->type() == QEvent::FileOpen)
      {
        QFileOpenEvent *openEvent = static_cast<QFileOpenEvent *>(event);
        emit this->receivedMessage(0, openEvent->url());
      }
      else
        return QApplication::event (event);

      return true;
    };

    public slots:
      void processMessage(quint32 instance, QByteArray msg) {
        emit this->receivedMessage(QVariant(instance), QVariant(QString(msg)));
      }

    signals:
      void receivedMessage(QVariant instanceID, QVariant message);
};
