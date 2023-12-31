#include <clocale>

#define APP_TITLE "Stremio - Freedom to Stream"

#include "systemtray.h"

#include "main.h"
#include "stremioprocess.h"
#include "mpv.h"
#include "screensaver.h"

void InitializeParameters(QQmlApplicationEngine *engine, MainApp &app)
{
    QQmlContext *ctx = engine->rootContext();
    SystemTray *systemTray = new SystemTray();

    ctx->setContextProperty("applicationDirPath", QGuiApplication::applicationDirPath());
    ctx->setContextProperty("appTitle", QString(APP_TITLE));

    // Set access to an object of class properties in QML context
    ctx->setContextProperty("systemTray", systemTray);

#ifdef QT_DEBUG
    ctx->setContextProperty("debug", true);
#else
    ctx->setContextProperty("debug", false);
#endif
}

int main(int argc, char **argv)
{
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS", "--autoplay-policy=no-user-gesture-required");
#ifdef _WIN32
    // Default to ANGLE (DirectX), because that seems to eliminate so many issues on Windows
    // Also, according to the docs here: https://wiki.qt.io/Qt_5_on_Windows_ANGLE_and_OpenGL, ANGLE is also preferrable
    // We do not need advanced OpenGL features but we need more universal support

    QApplication::setAttribute(Qt::AA_UseOpenGLES);
    auto winVer = QSysInfo::windowsVersion();
    if (winVer <= QSysInfo::WV_WINDOWS8 && winVer != QSysInfo::WV_None)
    {
        qputenv("NODE_SKIP_PLATFORM_CHECK", "1");
    }
    if (winVer <= QSysInfo::WV_WINDOWS7 && winVer != QSysInfo::WV_None)
    {
        qputenv("QT_ANGLE_PLATFORM", "d3d9");
    }
#endif

// This is really broken on Linux
#ifndef Q_OS_LINUX
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QApplication::setApplicationName("Stremio");
    QApplication::setApplicationVersion(STREMIO_SHELL_VERSION);
    QApplication::setOrganizationName("Smart Code ltd");
    QApplication::setOrganizationDomain("stremio.com");

    MainApp app(argc, argv, true);

    app.setWindowIcon(QIcon(":/images/stremio_window.png"));

    // Qt sets the locale in the QGuiApplication constructor, but libmpv
    // requires the LC_NUMERIC category to be set to "C", so change it back.
    std::setlocale(LC_NUMERIC, "C");

    static QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    qmlRegisterType<Process>("com.stremio.process", 1, 0, "Process");
    qmlRegisterType<ScreenSaver>("com.stremio.screensaver", 1, 0, "ScreenSaver");
    qmlRegisterType<MpvObject>("com.stremio.libmpv", 1, 0, "MpvObject");

    InitializeParameters(engine, app);

    engine->load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject::connect(&app, SIGNAL(receivedMessage(QVariant, QVariant)), engine->rootObjects().value(0),
                     SLOT(onAppMessageReceived(QVariant, QVariant)));
    int ret = app.exec();
    delete engine;
    engine = nullptr;
    return ret;
}
