import QtQuick 2.0

Row {
    id: counterP1

    property alias max: repeater.model
    property int amount: 0
    property int player: 1

    spacing: 20

    Repeater {
        id: repeater

        Image {
            source: res("pong/marker.png")

            Image {
                z: -1
                visible: index < amount
                onVisibleChanged: scaleAnim.running = true;
                source: res("pong/glow"+player+".png")
                anchors.centerIn: parent

                NumberAnimation on scale {
                    id: scaleAnim
                    from: 5
                    to: 1
                }
            }
        }


    }

}

