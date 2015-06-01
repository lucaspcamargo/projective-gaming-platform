import QtQuick 2.0

Rectangle
{
    id: splash

    anchors.fill: parent
    color: "#eff0f1"

    property alias status: splashLabel.text

    Rectangle
    {
        anchors.fill: parent
        gradient: Gradient  {
            GradientStop{
                position: 0
                color:  "#336600"
            }
            GradientStop{
                position: 1
                color:  "#112200"
            }
        }
    }

    Text
    {
        text: "Projective Game Platform for Public Spaces"
        color: "white"
        font.family: "Open Sans"
        font.weight: Font.Light
        font.pixelSize: 48
        x: 32
        y: 32
    }

    Text
    {
        text: "TIEVS84 - HTI Project\n420145 Lucas Pires Camargo"
        color: "white"
        font.family: "Open Sans"
        font.pixelSize: 32
        x: 32
        y: 96
    }


    Text
    {
        id: splashLabel
        anchors.fill: parent
        anchors.margins: 32
        text: "Initializing Camera"
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignBottom
        color: "white"
    }
}

