import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import qmlnect 1.0

ApplicationWindow {

    id: controlWindow

    title: qsTr("QMLnect")

    width: 854
    height: 480

    visibility: Window.Maximized
    visible: true

    property bool _NO_KINECT: false

    function res(url)
    {
        return Qt.resolvedUrl("file://"+cwd+"/res/"+url);
    }

    Item {

        id: container

        anchors.fill: parent
    }

    QNiTE {

        id: qnite

        onInitializedChanged:
        {
            splash.status = "Loading Game"
            gameContainer.active = true;
        }
    }

    ControlPanel {
        id: controlPanel

        anchors.fill: parent
    }

    SoundSystem
    {
        id: soundSystem
    }

    property var gameList: ["pong", "grid"]
    property int gameIndex: 0

    Loader
    {
        id: gameContainer
        asynchronous: true
        active: false
        source: gameList[gameIndex] + "/GameMain.qml"
        onStatusChanged: if(splash && status == Loader.Ready) splash.destroy();
    }

    ShaderEffectSource
    {
        id: gameSurface
        sourceItem: gameContainer
        hideSource: true
    }

    Splash
    {
        id: splash
    }

    property var viewers: []

    function updateGame(dt)
    {
        gameContainer.item.frame(dt);
    }

    function updateViewers()
    {
        for(var i = 0; i < viewers.length; i++)
        {
            viewers[i].update();
        }
    }

    function spawnViewer()
    {
        var c = Qt.createComponent("GameViewer.qml");
        var v = c.createObject();
        viewers.push( v );
    }

    property bool initializedTimer: false

    onFrameSwapped:
    {
        if(_NO_KINECT)
        {
            if(splash) {
                gameContainer.active = true;
                splash.destroy();
            }
        }
        else if(!qnite.initialized)
            qnite.initialize();

        if(gameContainer.status == Loader.Ready)
        {
            if(!initializedTimer)
            {
                qnite.utilStartTimer();
                initializedTimer = true;
            }

            var nsecsElapsed = qnite.utilGetElapsedNanos(true);

            updateGame( nsecsElapsed / 1.0e9 );
            updateViewers();
        }
    }

}
