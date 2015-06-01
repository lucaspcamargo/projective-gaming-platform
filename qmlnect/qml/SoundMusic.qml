import QtQuick 2.4
import qmlnect 1.0

QtObject {

    id: bgm

    property bool loop: true
    property url source: ""
    property url introSource: ""

    property real volume: 1.0
    property bool fadeEnabled: true

    Behavior on volume { enabled: fadeEnabled; NumberAnimation { easing.type: Easing.OutExpo; duration: 3000; } }

    onVolumeChanged: {

        if(!sndSource)
            return;

        if(volume == 0 )
            pause();
        else if(!playing() || paused())
            play();

        sndSource.setGain(volume);

    }

    property var sndSource: null
    property var sndStream: null
    property var sndIntroStream: null
    property var sndStreamer: null
    property var sndPlaylist: null

    Component.onCompleted:
    {
        var sndSys = soundSystem;
        var name = "BGM" + Math.random();

        sndSource = sndSys.createSource(name);
        sndSource.setGain(volume);

        if(!sndSource) {
            console.log("Failed to create source");
            return;
        }

        sndStream = sndSys.createStreamUrl(source, sndSource);
        if(!sndStream) return;

        if(introSource != "") sndIntroStream = sndSys.createStreamUrl(introSource, sndSource);

        sndPlaylist = sndSys.createStreamerPlaylist(sndSource);

        if(sndIntroStream)
        {
            sndPlaylist.createItem(sndIntroStream, false);
        }
        sndPlaylist.createItem(sndStream, loop);

        sndStreamer = sndSys.createStreamer(name, sndSource, sndPlaylist);

    }

    Component.onDestruction: {

        var sndSys = soundSystem;

        sndSys.destroyStreamer(sndStreamer);
        sndSys.destroySource(sndSource);

    }

    function play() {
        sndSource.play();
    }

    function pause() {
        sndSource.pause();
    }

    function stop() {
        sndSource.stop();
    }

    function rewind() {
        sndStreamer.rewind();
    }

    function seekZero() {
        sndStreamer.rewind();
    }

    function playing() {
        return sndSource.state == NSoundSource.SSS_PLAYING;
    }

    function paused() {
        return sndSource.state == NSoundSource.SSS_PAUSED;
    }
}

