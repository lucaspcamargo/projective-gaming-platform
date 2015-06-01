import QtQuick 2.0
import qmlnect 1.0

QtObject {
    property url source: ""
    property var soundBuffer: null
    property real gain: 1.0

    Component.onCompleted:
    {
        if(source == "") return;

        soundBuffer = soundSystem.buffer(source);

        if(soundBuffer == null)
        {
            soundBuffer = soundSystem.createBuffer(source);

            soundSystem.fillBuffer(soundBuffer, source);

        }
    }

    onSourceChanged: Component.onCompleted();

    function play(gainArg, pitch, xPos, yPos, zPos, attenuationScale)
    {
        var src = soundSystem.createSource(NSoundSource.SSR_SFX);
        src.gain *= gain;

        if(gainArg) src.gain *= gainArg;
        if(pitch) src.pitch = pitch;
        if(xPos) src.position = Qt.vector3d(xPos, yPos, zPos).times((attenuationScale? attenuationScale : 1));

        src.attachBuffer(soundBuffer);
        src.destroyAfterStopped = true;
        src.play();
    }
}
