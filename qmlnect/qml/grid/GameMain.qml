import QtQuick 2.4
import ".."
import "../helper"

GameBase {

    id: game

    width: 1280
    height: 720

    property real p1x: 100
    property real p1y: 100
    property var p1tile: null

    property real p2x: 1180
    property real p2y: 620
    property var p2tile: null

    ShaderEffect
    {

        id: plasmaBg
        anchors.fill: parent

        property real u_time: 0
        property vector2d u_k: Qt.vector2d(16, 9);


        function update(dt)
        {
            u_time = (u_time + dt) % (12 * Math.PI)
        }

        fragmentShader: "
        #define PI 3.1415926535897932384626433832795

        uniform float u_time;
        uniform vec2 u_k;
        varying vec2 qt_TexCoord0;

        void main() {
            float v = 0.0;
            vec2 c = (qt_TexCoord0 + vec2(-0.5, -0.5)) * u_k - u_k/2.0;
            v += sin((c.x+u_time));
            v += sin((c.y+u_time)/2.0);
            v += sin((c.x+c.y+u_time)/2.0);
            c += u_k/2.0 * vec2(sin(u_time/3.0), cos(u_time/2.0));
            v += sin(sqrt(c.x*c.x+c.y*c.y+1.0)+u_time);
            v = v/2.0;
            vec3 col = vec3(sin(PI*v), 1, cos(PI*v));
            gl_FragColor = vec4(col*.5/* + .5*/, 1);
        }"
    }

    Image
    {
        anchors.fill: parent
        source: res("grid/vignette2.png")
    }

    onUpdate:
    {
        var dt = 1.0/60.0;

        plasmaBg.update(dt);
    }

    property int levelIndex: -1
    property int numLevels: 4
    property int gridWidth: 9
    property int gridHeight: 5
    property int tileCount: gridWidth * gridHeight
    property int blankTileCount: -1
    property var gridData: [
        5,5,5,5,5,5,5,5,5,
        5,5,5,5,5,5,5,5,5,
        5,5,5,5,5,5,5,5,5,
        5,5,5,5,5,5,5,5,5,
        5,5,5,5,5,5,5,5,5
    ]

    Component.onCompleted: {
    }

    onBlankTileCountChanged: {

        if(blankTileCount < 0) return;

        if(blankTileCount == 0) {
            endGame(true);
        }

        var p1Count = countTilesOfType(3);
        var p2Count = countTilesOfType(4);
        var dif = Math.abs(p1Count - p2Count);

        if ( dif > blankTileCount )
            endGame(true);
    }

    function endGame(hasWinner) {

        if(!hasWinner)
        {

        }
        else
        {
            var p1Win = countTilesOfType(3) > countTilesOfType(4);
            sfxStart.play();

            (p1Win? voVictoryP1 : voVictoryP2).play();
            fillGrid(p1Win? 3 : 4);

            levelClean.running = true;

        }
    }


    Grid
    {
        id: tileGrid

        spacing: parent.height / 50
        anchors.centerIn: parent
        //anchors.margins: spacing * 2

        columns: gridWidth
        rows: gridHeight

        property real cellWidth: (game.width - tileGrid.spacing * 4) / gridWidth - tileGrid.spacing
        property real cellHeight: (game.height - tileGrid.spacing * 4) / gridHeight - tileGrid.spacing

        Repeater
        {
            model: gridWidth * gridHeight

            GridTile {
                width: Math.min(tileGrid.cellWidth, tileGrid.cellHeight)
                height: width
                tileIndex: index
                type: gridData[index]
            }

        }

    }

    PlayerMarker
    {
        id: p1Marker
        pointX: p1x
        pointY: p1y
    }

    PlayerMarker
    {
        id: p2Marker
        index: 1
        pointX: p2x
        pointY: p2y
    }

    Timer {
        id: gridFiller
        property int pos: 0
        property int type: 3
        property var map: null
        property int delay: 0
        interval: 20
        repeat: true

        onTriggered: {

            if(delay) {
                delay--;
                return;
            }

            setTileTypeByIndex(pos, map? map[pos] : type);

            pos++;

            if(pos == tileCount)
            {
                map = null;
                pos = 0;
                running = false;
                delay = 0;
            }
        }
    }

    function updatePlayer(player, px, py)
    {
        if(player == 0)
        {
            p1x = px;
            p1y = py;

            var newP1tile = tileGrid.childAt( p1x - tileGrid.x, p1y - tileGrid.y );

            if(newP1tile !== p1tile)
            {
                if(p1tile)
                    p1tile.hasP1 = false;

                if(newP1tile)
                    newP1tile.hasP1 = true;

                p1tile = newP1tile;
            }

        }
        else if(player == 1)
        {
            p2x = px;
            p2y = py;

            var newP2tile = tileGrid.childAt( p2x - tileGrid.x, p2y - tileGrid.y );

            if(newP2tile !== p2tile)
            {
                if(p2tile)
                    p2tile.hasP2 = false;

                if(newP2tile)
                    newP2tile.hasP2 = true;

                p2tile = newP2tile;
            }

        }
    }

    function setTileType(x, y, tileType)
    {
        if(x < 0 || y < 0) return;
        if (x >= gridWidth) return;
        if (y >= gridHeight) return;

        setTileTypeByIndex( y * gridWidth + x, tileType );
    }

    function setTileTypeByIndex(index, type)
    {
        var tmp = gridData;

        var balance = 0;
        if(gridData[index] === 0) balance--;
        if(type === 0) balance++;

        gridData[index] = type;

        gridData = tmp;

        if(blankTileCount >= 0) blankTileCount += balance;
    }

    function recountBlanks()
    {
        blankTileCount = countTilesOfType( 0 );
    }

    function countTilesOfType(type)
    {
        var count = 0;

        for(var i = 0; i < tileCount; i++)
        {
            if(gridData[i] === type)
                count ++;
        }

        return count;
    }

    function fillGrid(type)
    {
        var tmp = gridData;

        for(var i = 0; i < tileCount; i++)
        {
            tmp[i] = type;
        }

        gridData = tmp;
    }

    function setGrid(map)
    {
        var tmp = gridData;

        for(var i = 0; i < tileCount; i++)
        {
            tmp[i] = map[i];
        }

        gridData = tmp;
    }

    SequentialAnimation
    {
        id: levelClean
        running: true

        ScriptAction
        {
            script: {
                blankTileCount = -1;
            }
        }

        PauseAnimation {
            duration: 4000
        }

        ScriptAction
        {
            script: {
                gridFiller.map = null;
                gridFiller.type = 5;
                gridFiller.running = true;
            }
        }

        PauseAnimation {
            duration: 2000
        }

        ScriptAction
        {
            script: {
                gridFiller.map = maps["places"];
                gridFiller.running = true;
            }
        }

        PauseAnimation {
            duration: 1000
        }

        ScriptAction
        {
            script: {
                voPlaces.play();
            }
        }

        PauseAnimation {
            duration: 500
        }

        ScriptAction
        {
            script: {
                placementCheck.running = true;
            }
        }
    }

    Timer
    {
        id: placementCheck

        onTriggered: {
            levelCountdown.start();
        }
    }


    SequentialAnimation
    {
        id: levelCountdown

        ScriptAction
        {
            script: {
                voCountdown.play();
            }
        }

        PauseAnimation {
            duration: 500
        }

        ScriptAction
        {
            script: {
                setGrid(maps["places3"]);
            }
        }

        PauseAnimation {
            duration: 1000
        }

        ScriptAction
        {
            script: {
                setGrid(maps["places2"]);
            }
        }

        PauseAnimation {
            duration: 1200
        }

        ScriptAction
        {
            script: {
                setGrid(maps["places1"]);
            }
        }

        PauseAnimation {
            duration: 1500
        }

        ScriptAction
        {
            script: {
                placementCheck.stop();
                levelStart.running = true;
            }
        }
    }

    SequentialAnimation
    {
        id: levelStart

        ScriptAction
        {
            script: {
                levelIndex++;
                levelIndex %= numLevels;
                setGrid(maps["level"+levelIndex]);
                recountBlanks();
                sfxStart.play();
            }
        }
    }

    SoundMusic
    {
        id: bgm
        source: res("grid/bgm0.ogg")
        volume: 0.35

        Component.onCompleted: play()
    }

    SoundEffect
    {
        id: sfxStart
        source: res("grid/sfx/start.ogg")
        gain: 0.65

        Component.onCompleted: play()
    }

    SoundEffect
    {
        id: voVictoryP1
        source: res("grid/voice/victory-p1.ogg")
    }
    SoundEffect
    {
        id: voVictoryP2
        source: res("grid/voice/victory-p2.ogg")
    }
    SoundEffect
    {
        id: voPlaces
        source: res("grid/voice/places.ogg")
    }

    SoundEffect
    {
        id: voCountdown
        source: res("grid/voice/321.ogg")
    }

    property var maps: {
        "level0": [
                    3,0,1,0,0,0,0,0,0,
                    0,0,1,0,0,0,0,0,0,
                    0,0,1,0,2,0,1,0,0,
                    0,0,0,0,0,0,1,0,0,
                    0,0,0,0,0,0,1,0,4
                ],
                "level1": [
                    3,0,2,0,0,1,1,1,1,
                    1,0,0,0,0,0,1,1,1,
                    1,1,0,0,2,0,0,1,1,
                    1,1,1,0,0,0,0,0,1,
                    1,1,1,1,0,0 ,2,0,4
                ],

                "level2": [
                    3,0,0,0,2,0,0,0,2,
                    0,0,0,0,0,0,1,1,0,
                    0,1,0,0,0,0,0,1,0,
                    0,1,1,0,0,0,0,0,0,
                    2,0,0,0,2,0,0,0,4
                ],

                "level3": [
                    3,0,0,0,2,0,2,0,2,
                    0,0,0,0,0,0,0,0,0,
                    0,0,2,0,2,0,2,0,0,
                    0,0,0,0,0,0,0,0,0,
                    2,0,2,0,2,0,0,0,4
                ],

                "places": [
                    3,1,1,1,1,1,1,1,1,
                    1,1,1,1,1,1,1,1,1,
                    1,1,1,1,1,1,1,1,1,
                    1,1,1,1,1,1,1,1,1,
                    1,1,1,1,1,1,1,1,4
                ],

                "places3": [
                    3,1,1,5,5,1,1,1,1,
                    1,1,1,1,1,5,1,1,1,
                    1,1,1,5,5,1,1,1,1,
                    1,1,1,1,1,5,1,1,1,
                    1,1,1,5,5,5,1,1,4
                ],

                "places2": [
                    3,1,1,5,5,1,1,1,1,
                    1,1,1,1,1,5,1,1,1,
                    1,1,1,1,5,1,1,1,1,
                    1,1,1,5,1,1,1,1,1,
                    1,1,1,5,5,5,1,1,4
                ],

                "places1": [
                    3,1,1,1,5,1,1,1,1,
                    1,1,1,5,5,1,1,1,1,
                    1,1,1,1,5,1,1,1,1,
                    1,1,1,1,5,1,1,1,1,
                    1,1,1,5,5,5,1,1,4
                ]

    }

    FloorProjectionHelper
    {
        id: helper
    }

}

