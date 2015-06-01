import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.2

Window {

    id: viewerWindow
    title: "Game Viewport"

    width: gameSurface.sourceItem.width * height  / gameSurface.sourceItem.height
    height: 720

    color: "black"
    visible: true

    ShaderEffect {
        id: gameView
        property variant src: gameSurface
        width: parent.width
        //height: width * gameSurface.sourceItem.heigth/gameSurface.sourceItem.width
        height: 9*width/16

        //anchors.centerIn: parent
        anchors.fill: parent

        vertexShader: "
                   uniform highp mat4 qt_Matrix;
                   attribute highp vec4 qt_Vertex;
                   attribute highp vec2 qt_MultiTexCoord0;
                   varying highp vec2 coord;
                   void main() {
                       coord = qt_MultiTexCoord0;
                       gl_Position = qt_Matrix * qt_Vertex;
                   }"

        fragmentShader: "
                   varying highp vec2 coord;
                   uniform sampler2D src;
                   uniform lowp float qt_Opacity;
                   void main() {
                       lowp vec4 tex = texture2D(src, coord);
                       gl_FragColor = tex * qt_Opacity;
                   }"
    }

    Timer
    {
        interval: 16
        repeat: true
        running: true
        onTriggered: viewerWindow.update()
    }

}



