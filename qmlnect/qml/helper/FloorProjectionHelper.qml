import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0

ApplicationWindow {

    id: helper

    property bool useful: !_NO_KINECT

    visible: useful
    modality: Qt.NonModal

    title: "Kinect Helper"

    property vector3d calibration00: Qt.vector3d(505, -134, 2053)
    property vector3d calibration10: Qt.vector3d(-1027, -192, 2294)
    property vector3d calibration01: Qt.vector3d(712, -293, 2853)
    property vector3d calibration11: Qt.vector3d(-910, -351, 3109)

//    Settings {
//        property alias c00: helper.calibration00
//        property alias c10: helper.calibration10
//        property alias c01: helper.calibration01
//        property alias c11: helper.calibration11
//    }

    property vector3d projected00
    property vector3d projected10
    property vector3d projected01
    property vector3d projected11

    property bool trackFloor: false
    property vector3d floorPoint: Qt.vector3d(0, -1124.683349609375, 583.3001098632812)
    property vector3d floorNormal: Qt.vector3d(0.009607193991541862, 0.9969038367271423, -0.07804128527641296)

    property real floorConfidenceCurrent: 0
    property real floorConfidenceMirror: qnite.groundConfidence

    property var user2: null
    property var user1: null
    property vector3d projectedUser1: Qt.vector3d(0,0,0)
    property vector3d projectedUser2: Qt.vector3d(0,0,0)

    Timer {
        id: floorDelay
        interval: 1000
        running: true
        onTriggered: {
            console.log("Tracking floor");
            trackFloor = true;
        }

    }

    onFloorConfidenceMirrorChanged: {

        if(!trackFloor) return;
        if(floorConfidenceMirror == 0) return;

        if( floorConfidenceMirror >= floorConfidenceCurrent )
        {
            console.log("Updating floor with confidence: " + floorConfidenceMirror);

            // update floor
            floorPoint = qnite.groundPoint;
            floorNormal = qnite.groundNormal.normalized();
            floorConfidenceCurrent = floorConfidenceMirror;

            console.log(floorPoint.x +" "+ floorPoint.y +" "+ floorPoint.z);
            console.log(floorNormal.x +" "+ floorNormal.y +" "+ floorNormal.z);

            recalcProjection();
        }

    }

    function recalcProjection() {

        projected00 = floorProject(calibration00);
        projected10 = floorProject(calibration10);
        projected01 = floorProject(calibration01);
        projected11 = floorProject(calibration11);
    }


    function floorProject( vec ) {
        var v = vec.minus(floorPoint);
        var dist = v.crossProduct(floorNormal);
        return vec.minus(floorNormal.times(dist));
    }

    Component.onCompleted: {

        for(var i = 0; i < qnite.userCount; i++)
        {
            userFound(qnite.getUidByIndex(i).userId);
        }

        recalcProjection()
        qnite.userFound.connect(userFound)
        qnite.userLost.connect(userLost)
    }

    function userFound(uid)
    {
        if(!user1) {
            user1 = qnite.getUser(uid);
            user1.centerOfMassChanged.connect(onUser1CenterOfMassChanged);
        }
        else if(!user2) {
            user2 = qnite.getUser(uid);
            user2.centerOfMassChanged.connect(onUser2CenterOfMassChanged);
        } else {
            if(user1.centerOfMass === Qt.vector3d(0,0,0))
            {
                user1.centerOfMassChanged.disconnect(onUser1CenterOfMassChanged);
                user1 = null;
                userFound(uid);
            } else if(user2.centerOfMass === Qt.vector3d(0,0,0))
            {
                user2.centerOfMassChanged.disconnect(onUser2CenterOfMassChanged);
                user2 = null;
                userFound(uid);
            }
        }
    }

    function userLost(uid)
    {
        if(user1 && user1.userId == uid) user1 = null;
        if(user2 && user2.userId == uid) user2 = null;
    }

    function onUser1CenterOfMassChanged( com )
    {
        projectedUser1 = floorProject(com);
        var uv = getFloorUV( projectedUser1 );
        game.updatePlayer(0, uv.x*game.width, uv.y*game.height);
    }

    function onUser2CenterOfMassChanged( com )
    {
        projectedUser2 = floorProject(com);
        var uv = getFloorUV( projectedUser2 );
        game.updatePlayer(1, uv.x*game.width, uv.y*game.height);
    }

    function getDistanceToLine(x0, y0, x1, y1, x2, y2)
    {
        return Math.abs((y2-y1)*x0 - (x2-x1)*y0 + x2*y1 - y2*x1)/Math.sqrt((y2-y1)*(y2-y1) + (x2-x1)*(x2-x1));
    }

    function getDistanceToLinePoints(p, a, b)
    {
        return getDistanceToLine(p.x, p.z, a.x, a.z, b.x, b.z);
    }

    function getFloorUV( p )
    {
        var du0 = getDistanceToLinePoints(p, projected01, projected00);
        var du1 = getDistanceToLinePoints(p, projected10, projected11);

        var dv0 = getDistanceToLinePoints(p, projected11, projected01);
        var dv1 = getDistanceToLinePoints(p, projected00, projected10);

        var u = du0/(du0+du1);
        var v = dv0/(dv0+dv1);

        if(btnInvX.checked) u = 1 - u;
        if(btnInvY.checked) v = 1 - v;

        return Qt.vector2d(u, v)

    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            text: floorConfidenceCurrent > 0.5? "Floor calibrated" : "Floor calibrating..."
        }

        RowLayout{

            Label{text: "Capture: "}
            Item{ width: 10 }
            Button {
                text: "00"
                onClicked: {
                    if(user1 || user2) {
                        calibration00 = (user1? user1 : user2).centerOfMass;
                        recalcProjection();
                    }
                    else console.log("No user to get position from");
                }
            }
            Button {
                text: "10"
                onClicked: {
                    if(user1 || user2) {
                        calibration10 = (user1? user1 : user2).centerOfMass;
                        recalcProjection();
                    }
                    else console.log("No user to get position from");
                }
            }
            Button {
                text: "01"
                onClicked: {
                    if(user1 || user2) {
                        calibration01 = (user1? user1 : user2).centerOfMass;
                        recalcProjection();
                    }
                    else console.log("No user to get position from");
                }
            }
            Button {
                text: "11"
                onClicked: {
                    if(user1 || user2) {
                        calibration11 = (user1? user1 : user2).centerOfMass;
                        recalcProjection();
                    }
                    else console.log("No user to get position from");
                }
            }
            Button {
                id: btnInvX
                text: "Inv X"
                checkable: true
                checked: true
            }

            Button {
                id: btnInvY
                text: "Inv Y"
                checkable: true
            }
        }

        Rectangle
        {
            id: fieldViewer
            color: "black"
            width: 512
            height: 512

            property real originOffset: width / 2.0
            property real originScale: originOffset/10

            // crosshairs

            Rectangle {
                color: "#333"
                width: parent.width
                height: 1
                anchors.centerIn: parent
            }

            Rectangle {
                color: "#333"
                width: parent.width
                height: 1
                anchors.centerIn: parent
                rotation: 90
            }

            // floorpoints
            FloorProjectionHPointer {
                color: "red"; text: "00"
                x: fieldViewer.originOffset - projected00.x / fieldViewer.originScale
                y: fieldViewer.originOffset + projected00.z / fieldViewer.originScale
            }
            FloorProjectionHPointer {
                color: "red"; text: "01"
                x: fieldViewer.originOffset - projected01.x / fieldViewer.originScale
                y: fieldViewer.originOffset + projected01.z / fieldViewer.originScale
            }
            FloorProjectionHPointer {
                color: "red"; text: "10"
                x: fieldViewer.originOffset - projected10.x / fieldViewer.originScale
                y: fieldViewer.originOffset + projected10.z / fieldViewer.originScale
            }
            FloorProjectionHPointer {
                color: "red"; text: "11"
                x: fieldViewer.originOffset - projected11.x / fieldViewer.originScale
                y: fieldViewer.originOffset + projected11.z / fieldViewer.originScale
            }

            // users
            FloorProjectionHPointer {
                color: "lightblue"; size: 5; text: "U1"
                x: fieldViewer.originOffset - projectedUser1.x / fieldViewer.originScale
                y: fieldViewer.originOffset + projectedUser1.z / fieldViewer.originScale
            }
            FloorProjectionHPointer {
                color: "orange"; size: 5; text: "U2"
                x: fieldViewer.originOffset - projectedUser2.x / fieldViewer.originScale
                y: fieldViewer.originOffset + projectedUser2.z / fieldViewer.originScale
            }
        }
    }
}

