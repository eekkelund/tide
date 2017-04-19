TARGET = harbour-tide-editor

CONFIG += sailfishapp

DEFINES += APP_VERSION=\"\\\"$${VERSION}\\\"\"

SOURCES += src/harbour-tide.cpp \
    src/realhighlighter.cpp \
    src/documenthandler.cpp \
    src/iconprovider.cpp \
    src/keyboardshortcut.cpp

OTHER_FILES += qml/harbour-tide.qml \
    qml/cover/CoverPage.qml \
    qml/pages/AddFileDialog.qml \
    qml/pages/RestoreDialog.qml \
    qml/pages/MainPage.qml \
    qml/pages/SettingsPage.qml \
    translations/*.ts \
    harbour-tide-editor.desktop \
    rpm/harbour-tide-editor.spec

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

CONFIG += sailfishapp_i18n

TRANSLATIONS += translations/harbour-tide-sv.ts\
    translations/harbour-tide-nl.ts

DISTFILES += \
    qml/python/openFile.py \
    qml/python/editFile.py \
    qml/python/addFile.py \
    qml/python/settings.py \
    qml/pages/AboutPage.qml \
    qml/pages/SplitPage.qml \
    qml/pages/EditorPage.qml \
    qml/components/TopBar.qml

HEADERS += \
    src/realhighlighter.h \
    src/documenthandler.h \
    src/iconprovider.h \
    src/keyboardshortcut.h

RESOURCES += \
    src/dictionarys.qrc

