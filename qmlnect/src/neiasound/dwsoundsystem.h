#ifndef DWSOUNDSYSTEM_H
#define DWSOUNDSYSTEM_H

#include "nSoundSystem.h"
#include <QUrl>

class nSoundStream;

class DWSoundSystem : public nSoundSystem
{
    Q_OBJECT
public:
    explicit DWSoundSystem(QObject *parent = 0);

signals:

public slots:

    nSoundStream * createStreamUrl(QUrl stream, QObject * parent);
    void fillBuffer(nSoundBuffer * buf, QUrl url);

private:
};

#endif // DWSOUNDSYSTEM_H
