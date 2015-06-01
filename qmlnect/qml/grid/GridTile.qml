import QtQuick 2.0
import ".."

Item {
    id: tile

    property int tileIndex: -1
    property int type: 0
    property var colors: ["white", "black", "red", "#00a7b3", "#ff7300", "magenta"]
    property color randomColor: "magenta"

    property real brightness: 0.0
    scale: 1 + 0.3*brightness

    property bool hasP1: type == 3
    property bool hasP2: type == 4

    Timer {
        id: colorRandomizer
        running: type == 5
        repeat: true
        interval: 100
        onTriggered: randomColor = Qt.lighter(Qt.rgba(Math.random(), Math.random(), Math.random(), 1.0))
    }

    onHasP1Changed: {

        if(!hasP1) return;

        if(type == 0)
        {
            sfxSwitch.play();
            swAnim.running = true;
            setTileTypeByIndex(tileIndex, 3);
        }
        if(type == 2)
        {
            explode();
        }
    }

    onHasP2Changed: {
        if(!hasP2) return;

        if(type == 0)
        {
            sfxSwitch2.play();
            swAnim.running = true;
            setTileTypeByIndex(tileIndex, 4);
        }
        if(type == 2)
        {
            explode();
        }
    }

    function explode()
    {
        sfxBomb.play();
        explodeAnim.running = true;

        var myX = tileIndex % gridWidth;
        var myY = (tileIndex - myX) / gridWidth;

        var newType = hasP1? 4 : 3;

        setTileTypeByIndex(tileIndex, 1);
        setTileType(myX - 1, myY - 1, newType );
        setTileType(myX + 0, myY - 1, newType );
        setTileType(myX + 1, myY - 1, newType );

        setTileType(myX - 1, myY, newType );
        setTileType(myX + 1, myY, newType );

        setTileType(myX - 1, myY + 1, newType );
        setTileType(myX + 0, myY + 1, newType );
        setTileType(myX + 1, myY + 1, newType );
    }

    Rectangle
    {
        id: fill
        color: type == 5? randomColor : colors[type]

        anchors.fill: parent
        opacity: 0.85 + 0.15 * brightness
        border.color: "white"
        border.width: width/20

        radius: border.width

        Behavior on color { ColorAnimation { duration: 100} }

    }

    property string icon: type == 2? "skull" : ""
    Image {
        id: tileIcon
        source: icon === "" ? "" : res("grid/"+icon+".png")
        anchors.fill: parent
    }

    Rectangle
    {
        id: blink
        anchors.fill: fill
        radius: fill.radius
        color: Qt.lighter(fill.color)
        opacity: Math.max(brightness, throb)
    }

    Rectangle
    {
        id: explodeEffect
        opacity: 0
        color: "transparent"
        border.width: width / 10
        border.color: "red"

        anchors.fill: parent
        radius: width / 2

        SequentialAnimation {

            id: explodeAnim

            ParallelAnimation
            {

                NumberAnimation {
                    target: explodeEffect
                    property: "scale"
                    from: 1
                    to: 3
                }
                NumberAnimation {
                    target: explodeEffect
                    property: "opacity"
                    from: 1
                    to: 0
                }
            }

            ScriptAction {
                script: {
                    explodeEffect.scale = 1;
                }
            }

        }

    }

    ParallelAnimation
    {
        id: swAnim

        NumberAnimation {
            target: tile
            property: "brightness"
            from: 1
            to: 0
        }
    }

    property real throb: 0
    NumberAnimation on throb {
        loops: Animation.Infinite
        running: true
        from: 0
        to: 0.2
        easing.type: Easing.SineCurve

        duration: 200 + 100*Math.random()
    }

    SoundEffect
    {
        id: sfxSwitch
        source: res("grid/sfx/switch.ogg")
        gain: 2
    }

    SoundEffect
    {
        id: sfxSwitch2
        source: res("grid/sfx/switch2.ogg")
        gain: 0.5
    }

    SoundEffect
    {
        id: sfxBomb
        source: res("grid/sfx/bomb.ogg")
    }
}

