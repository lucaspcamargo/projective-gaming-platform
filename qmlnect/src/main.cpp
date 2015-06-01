#include <QApplication>
#include <QQmlApplicationEngine>

#include <QtQml>
#include <QDir>

#include "qnite.h"
#include "qniteuser.h"
#include "qnitetrackerrenderer.h"
#include "qnitecolorrenderer.h"

#include "neiasound/dwsoundsystem.h"
#include "neiasound/nSoundBag.h"
#include "neiasound/nSoundBuffer.h"
#include "neiasound/nSoundListener.h"
#include "neiasound/nSoundSource.h"
#include "neiasound/nSoundStream.h"
#include "neiasound/nSoundStreamer.h"
#include "neiasound/nSoundStreamerPlaylist.h"

#include "util/imagedata.h"


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

#define PACKAGE_VERSION "qmlnect", 1, 0,

    qmlRegisterType<QNiTE>("qmlnect", 1, 0, "QNiTE");
    qmlRegisterType<QNiTETrackerRenderer>("qmlnect", 1, 0, "QNiTETrackerRenderer");
    qmlRegisterType<QNiTEColorRenderer>("qmlnect", 1, 0, "QNiTEColorRenderer");
    qmlRegisterUncreatableType<QNiTEUser>("qmlnect", 1, 0, "QNiTEUser", "This class cannot be created directly. You can get references to tracked users from the QNiTE class.");

    qmlRegisterType<DWSoundSystem>("qmlnect", 1, 0, "SoundSystem");
    qmlRegisterUncreatableType<nSoundSystem>( PACKAGE_VERSION "NSoundSystem", QStringLiteral("") );
    qmlRegisterUncreatableType<nSoundBag>( PACKAGE_VERSION "NSoundBag", QStringLiteral("") );
    qmlRegisterUncreatableType<nSoundBuffer>( PACKAGE_VERSION "NSoundBuffer", QStringLiteral("") );
    qmlRegisterUncreatableType<nSoundListener>( PACKAGE_VERSION "NSoundListener", QStringLiteral("") );
    qmlRegisterUncreatableType<nSoundSource>( PACKAGE_VERSION "NSoundSource", QStringLiteral("") );
    qmlRegisterUncreatableType<nSoundStream>( PACKAGE_VERSION "NSoundStream", QStringLiteral("") );
    qmlRegisterUncreatableType<nSoundStreamer>( PACKAGE_VERSION "NSoundStreamer", QStringLiteral("") );
    qmlRegisterUncreatableType<nSoundStreamerPlaylist>( PACKAGE_VERSION "NSoundStreamerPlaylist", QStringLiteral("") );

    qmlRegisterType<ImageData>("qmlnect", 1, 0, "ImageData");

    qmlProtectModule("qmlnect", 1);

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("cwd", QDir::currentPath());
    engine.rootContext()->setContextProperty("qmlEngine", &engine);
    engine.load(QUrl(QStringLiteral("qrc:/qml/ControlWindow.qml")));

    return app.exec();
}
