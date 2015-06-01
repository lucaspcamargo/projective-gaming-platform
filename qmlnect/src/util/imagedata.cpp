#include "imagedata.h"

ImageData::ImageData(QObject *parent) : QObject(parent)
{

}

ImageData::~ImageData()
{

}

void ImageData::reloadImage()
{
    m_image.load(m_imageSource.toLocalFile());

}

QColor ImageData::pixel(int x, int y)
{
    return QColor(m_image.pixel(x, y));

}

