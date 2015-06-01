#ifndef IMAGEDATA_H
#define IMAGEDATA_H

#include <QObject>
#include <QImage>
#include <QUrl>
#include <QColor>

class ImageData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl imageSource READ imageSource WRITE setImageSource NOTIFY imageSourceChanged)

public:
    explicit ImageData(QObject *parent = 0);
    ~ImageData();

    QUrl imageSource() const
    {
        return m_imageSource;
    }

signals:

    void imageSourceChanged(QUrl arg);

public slots:

void setImageSource(QUrl arg)
{
    if (m_imageSource == arg)
        return;

    m_imageSource = arg;
    emit imageSourceChanged(arg);

    reloadImage();
}

bool isNull() {
    return m_image.isNull();
}

void reloadImage();

QColor pixel(int x, int y);

private:
QImage m_image;
QUrl m_imageSource;
};

#endif // IMAGEDATA_H
