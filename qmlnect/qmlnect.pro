TEMPLATE = app

QT += qml quick widgets

SOURCES += \
    src/qnite.cpp \
    src/main.cpp \
    src/qnitetrackerrenderer.cpp \
    src/qnitecolorrenderer.cpp \
    src/neiasound/dwsoundsystem.cpp \
    src/neiasound/nSoundBag.cpp \
    src/neiasound/nSoundBuffer.cpp \
    src/neiasound/nSoundEffectParameters.cpp \
    src/neiasound/nSoundListener.cpp \
    src/neiasound/nSoundScriptMetatypes.cpp \
    src/neiasound/nSoundSource.cpp \
    src/neiasound/nSoundStream.cpp \
    src/neiasound/nSoundStreamer.cpp \
    src/neiasound/nSoundStreamerPlaylist.cpp \
    src/neiasound/nSoundSystem.cpp \
    src/neiasound/stb_vorbis/nvorbisstream.cpp \
    src/neiasound/wav/nwavestream.cpp \
    src/neiasound/sndfile/nSndfileStream.cpp \
    src/neiasound/util/nEfxHelper.cpp \
    src/util/imagedata.cpp \
    src/qniteuser.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    src/qnite.h \
    src/qnitetrackerrenderer.h \
    src/qnitecolorrenderer.h \
    src/neiasound/dwsoundsystem.h \
    src/neiasound/nSoundBag.h \
    src/neiasound/nSoundBuffer.h \
    src/neiasound/nSoundEffectParameters.h \
    src/neiasound/nSoundFormat.h \
    src/neiasound/nSoundListener.h \
    src/neiasound/nSoundScriptMetatypes.h \
    src/neiasound/nSoundSource.h \
    src/neiasound/nSoundSourceRole.h \
    src/neiasound/nSoundStream.h \
    src/neiasound/nSoundStreamer.h \
    src/neiasound/nSoundStreamerPlaylist.h \
    src/neiasound/nSoundSystem.h \
    src/neiasound/stb_vorbis/nvorbisstream.h \
    src/neiasound/wav/nwavestream.h \
    src/neiasound/sndfile/nSndfileStream.h \
    src/neiasound/util/efx-util.h \
    src/neiasound/util/nEfxHelper.h \
    src/util/imagedata.h \
    src/qniteuser.h

NITE2_PATH = ${HOME}/kinect/NiTE-Linux-x64-2.2
OPENNI2_PATH = ${HOME}/kinect/openni2

INCLUDEPATH += $${NITE2_PATH}/Include \
               $${OPENNI2_PATH}/Include

INCLUDEPATH += /home/demola/kinect/openni2/Include \
               /home/demola/kinect/NiTE-Linux-x64-2.2/Include

LIBS += $${NITE2_PATH}/Redist/libNiTE2.so\
               $${OPENNI2_PATH}/Bin/x64-Release/libOpenNI2.so


unix: CONFIG += link_pkgconfig
unix: PKGCONFIG += openal sndfile
