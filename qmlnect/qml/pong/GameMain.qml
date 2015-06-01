import QtQuick 2.0
import ".."
import "../helper"
import qmlnect 1.0

GameBase {

    id: game

    width: 1280
    height: 720

    property real p1x
    property real p1y

    property real p2x
    property real p2y

    property int paddleMargin: paddle1.x + paddle1.width
    property real maxScore: 5
    property real p1Score: 0
    property real p2Score: 0

    Image {
        id: spaceBg
        height: parent.height
        width: height * sourceSize.width / sourceSize.height
        source: res("pong/space.jpg")

        NumberAnimation on x {
            from: 0
            to: - (spaceBg.width - game.width)
            duration: 20000
            easing.type: Easing.SineCurve
            loops: Animation.Infinite
            running: true
        }    }


    Rectangle {
        id: fieldFlash

        anchors.centerIn: field

        width: 970
        height: 560

        opacity: 0

        NumberAnimation on opacity {
            id: flashAnim
            from: 0
            to: 0
            duration: 50
        }

    }

    Image {
        id: fieldBg
        source: res("pong/field.png")

    }

    Item
    {
        id: field
        width: 1050
        height: 600
        anchors.centerIn: parent


        Item {
            id: ball
            width: 70
            height: 70
            x: 600
            y: 400

            property real defaultSpeedMagnitude: 400 * Math.sqrt(2)

            property real xs: defaultSpeedMagnitude / Math.sqrt(2)
            property real ys: defaultSpeedMagnitude / Math.sqrt(2)

            property real r: width / 2
            property real cx: x + r
            property real cy: y + r

            Image {
                id: ballSprite
                source: res("pong/ball.png")
                anchors.centerIn: parent;
            }
        }

        Item {
            id: paddle1

            x: 0
            y: Math.max( 0, Math.min( p1y - field.y - paddle1.height / 2 , field.height - paddle1.height) )

            height: 194
            width: 20 + 50

            Image {
                source: res("pong/p1.png")
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.right
                anchors.horizontalCenterOffset: -10
            }
        }

        Item {
            id: paddle2

            x: field.width - paddle1.x - paddle2.width
            y: Math.max( 0, Math.min( p2y - field.y - paddle2.height / 2 , field.height - paddle2.height) )

            height: paddle1.height
            width: paddle1.width

            Image {
                source: res("pong/p2.png")
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.left
                anchors.horizontalCenterOffset: 10
            }
        }

    }

    ScoreMarker {
        id: counterP1
        max: maxScore
        amount: p1Score
        player: 1

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
    }

    ScoreMarker {
        id: counterP2
        max: maxScore
        amount: p2Score
        player: 2

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        rotation: 180
    }

    function updatePlayer(player, px, py)
    {
        if(player == 0)
        {
            p1x = px;
            p1y = py;
        }
        else if(player == 1)
        {
            p2x = px;
            p2y = py;
        }
    }

    onUpdate: {

        if(!_NO_KINECT)
            if(!(helper.user1 && helper.user2)) return;

        ball.x += ball.xs * dt;
        ball.y += ball.ys * dt;

        if(ball.y < 0) {
            ball.y = -ball.y;
            ball.ys = -ball.ys;
            ballImpact(true);
        }

        if(ball.y > field.height - ball.height) {
            ball.y = field.height - ball.height;
            ball.ys = -ball.ys;
            ballImpact(true);
        }

        if( intersects(ball, paddle1) ) {
            ball.x = paddle1.x + paddle1.width;
            var nx = Math.sqrt( ball.xs*ball.xs + ball.ys*ball.ys );
            var ny = 0;

            var alpha = (ball.y + ball.r - (paddle1.y + paddle1.height/2)) / (paddle1.height / 2);
            alpha = Math.min(1, Math.max(-1, alpha));
            ball.xs = nx * Math.cos(alpha) - ny * Math.sin(alpha);
            ball.ys = nx * Math.sin(alpha) - ny * Math.cos(alpha);

            paddleSfx.play();
        }

        if( intersects(ball, paddle2) ) {
            ball.x = Math.min(ball.x, paddle2.x - ball.width);
            var nx = -Math.sqrt( ball.xs*ball.xs + ball.ys*ball.ys );
            var ny = 0;

            var alpha = -(ball.y + ball.r - (paddle2.y + paddle2.height/2)) / (paddle2.height / 2);
            alpha = Math.min(1, Math.max(-1, alpha));
            ball.xs = nx * Math.cos(alpha) - ny * Math.sin(alpha);
            ball.ys = nx * Math.sin(alpha) - ny * Math.cos(alpha);

            paddleSfx.play();
        }

        if(ball.x < 0) {
            ball.x = -ball.x;
            ball.xs = -ball.xs;
            ballImpact(true);
            p2Score++;
            scoreSfx.play();
            resetBallSpeed();
        }      

        if(ball.x > field.width - ball.width){
            ball.x = field.width - ball.width;
            ball.xs = -ball.xs;
            ballImpact(true);
            p1Score++;
            scoreSfx.play();
            resetBallSpeed();
        }

        if(p1Score >= maxScore || p2Score >= maxScore) {

            if(p1Score > p2Score)
            {
                voVictoryP1.play();
                voVictoryP1.play();
                voVictoryP1.play();
            }
            else
            {
                voVictoryP2.play();
                voVictoryP2.play();
                voVictoryP2.play();
            }
            p1Score = 0;
            p2Score = 0;

            ball.x = (field.width - ball.width) / 2.0;
            ball.y = (field.height - ball.height) / 2.0;
            ball.xs = 200;
            ball.ys = 200;

            scoreSfx.play();
        }
    }

    function resetBallSpeed() {
        var l = Math.sqrt(ball.xs*ball.xs + ball.ys*ball.ys);
        ball.xs = ball.defaultSpeedMagnitude * ball.xs / l;
        ball.ys = ball.defaultSpeedMagnitude * ball.ys / l;
    }

    Timer
    {
        interval: 1000
        repeat: true
        running: true
        onTriggered: { ball.xs *= 1.025; ball.ys *= 1.025 }
    }

    function ballImpact( walls ) {
        flashAnim.running = true;
        wallSfx.play();
    }

    function intersects(circle, rect)
    {
        var cdx = Math.abs(circle.x - rect.x);
        var cdy = Math.abs(circle.y - rect.y);
        var circleDistance = Qt.vector2d(cdx, cdy);

        if (circleDistance.x > (rect.width/2 + circle.r)) { return false; }
        if (circleDistance.y > (rect.height/2 + circle.r)) { return false; }

        if (circleDistance.x <= (rect.width/2)) { return true; }
        if (circleDistance.y <= (rect.height/2)) { return true; }

        var cornerDistance_sq = (circleDistance.x - rect.width/2)^2 +
                             (circleDistance.y - rect.height/2)^2;

        return (cornerDistance_sq <= (circle.r^2));
    }

    Component {
        id: ballImpactVertical

        Image {}

    }

    Timer {

    }

    SoundMusic {
        id: bgm
        source: res("grid/bgm1.ogg")
        volume: 0.35

        Component.onCompleted: play()
    }

    SoundEffect {
        id: startSfx
        source: res("pong/sfx/start.ogg")
        Component.onCompleted: play();
    }

    SoundEffect {
        id: scoreSfx
        source: res("pong/sfx/score.ogg")
    }

    SoundEffect {
        id: wallSfx
        source: res("pong/sfx/wallBounce.ogg")
    }

    SoundEffect {
        id: paddleSfx
        source: res("pong/sfx/paddleBounce.ogg")
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

    Rectangle {

        id: p1m
        opacity: 0.5

        width: 200
        height: width
        radius: width / 2

        property int index: 0
        property real pointX: 0
        property real pointY: 0

        x: p1x - width/2
        y: p1y - width/2

        color: "transparent"
        border.width: width / 20
        border.color: ["#00a7b3", "#ff7300"][0]
    }
    Rectangle {

        id: p2m
        opacity: 0.5

        width: 200
        height: width
        radius: width / 2

        property int index: 0
        property real pointX: 0
        property real pointY: 0

        x: p2x - width/2
        y: p2y - width/2

        color: "transparent"
        border.width: width / 20
        border.color: ["#00a7b3", "#ff7300"][1]
    }


    FloorProjectionHelper
    {
        id: helper
    }
}
