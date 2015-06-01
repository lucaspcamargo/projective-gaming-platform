import QtQuick 2.0

Rectangle {

    width: 1280
    height: 720

    property real gameTime
    property real frameTime
    signal update(real dt)

    function frame(dt)
    {
        frameTime = dt;
        gameTime += frameTime;

        update(dt);

    }

}

