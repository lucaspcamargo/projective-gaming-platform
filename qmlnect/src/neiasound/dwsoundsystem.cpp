#include "dwsoundsystem.h"
#include "nSoundSystem.h"
#include "nSoundStream.h"
#include "nSoundBuffer.h"
#include "nSoundListener.h"

#include "wav/nwavestream.h"
#include "stb_vorbis/nvorbisstream.h"
#include <QFile>
#include <QQmlApplicationEngine>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

DWSoundSystem::DWSoundSystem(QObject *parent) :
    nSoundSystem(parent)
{
    listener()->updateManual(QVector3D(0,0,0), QVector3D(0,0,-1), QVector3D(0,1,0), QVector3D(0,0,0));
    listener();
}

nSoundStream* DWSoundSystem::createStreamUrl(QUrl url, QObject *parentObj)
{
    nSoundStream * stream;

    if(!url.toLocalFile().isEmpty())
    {
        QFile * file = new QFile(url.toLocalFile());
        file->open(QIODevice::ReadOnly);

        if(file->fileName().endsWith(".ogg"))
            stream = new nVorbisStream(file, parentObj);
        else
            stream = new nWaveStream (file, SF_WAVE_HEADER, -1, -1, parentObj);

        file->setParent(stream);
    }

    qDebug("creating Stream done");

    return stream;

}

void DWSoundSystem::fillBuffer(nSoundBuffer *buf, QUrl url)
{
    qDebug("Filling Buffer");
    nSoundStream * stream = createStreamUrl(url, 0);
    buf->setData(stream);
    delete stream;
    qDebug("Filling Buffer Done");
}
