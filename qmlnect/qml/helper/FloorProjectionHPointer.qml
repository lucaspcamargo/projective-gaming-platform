import QtQuick 2.0

Item {

    property alias color: p.color
    property alias text: t.text
    property real size: 3

    Rectangle {
        id: p
        anchors.centerIn: parent
        width: size
        height: size
        radius: size/2
    }

    Text {
        id: t
        color: parent.color; y: -height; text: "00"
        x: size / 2
    }
}

