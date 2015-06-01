import QtQuick 2.0

Rectangle {

    id: marker

    width: 150
    height: width
    radius: width / 2

    property int index: 0
    property real pointX: 0
    property real pointY: 0

    x: pointX - width/2
    y: pointY - width/2


    color: "#a0ffffff"
    border.width: width / 10
    border.color: ["#00a7b3", "#ff7300"][index]

    Grid {
        id: dots

        anchors.centerIn: parent
        columns: 2
        spacing: index? parent.width / 10 : 0

        Repeater {
            model: index + 1


            Rectangle {
                color: marker.border.color

                width: marker.width * 0.2
                height: width
                radius: width/2
            }

        }
    }
}

