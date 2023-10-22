TEMPLATE = app
TARGET = stremio
VERSION=4.4.164
QMAKE_TARGET_BUNDLE_PREFIX = com.company
DEFINES += STREMIO_SHELL_VERSION=\\\"$$VERSION\\\"
ICON = images/stremio.icns
QMAKE_INFO_PLIST = mac/Info.plist

QT += qml quick network widgets webengine webchannel dbus
WEBENGINE_CONFIG+=use_proprietary_codecs
CONFIG += c++11

mac {
    QMAKE_LFLAGS_SONAME  = -Wl,-install_name,@executable_path/../Frameworks/
    LIBS += -framework CoreFoundation
    QMAKE_RPATHDIR += @executable_path/../Frameworks
    QMAKE_RPATHDIR += @executable_path/lib
}

QT_CONFIG -= no-pkg-config
CONFIG += link_pkgconfig debug
PKGCONFIG += mpv

SOURCES += src/main.cpp \
    src/mpv.cpp \
    src/stremioprocess.cpp \
    src/screensaver.cpp \
    src/systemtray.cpp

RESOURCES += src/qml.qrc
QML_IMPORT_PATH = src

HEADERS += src/main.h \
    src/mpv.h \
    src/stremioprocess.h \
    src/screensaver.h \
    src/systemtray.h

DESTDIR = ./build
OBJECTS_DIR = ./build/obj
MOC_DIR = ./build/moc
