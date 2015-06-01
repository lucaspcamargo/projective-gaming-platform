import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import qmlnect 1.0

TabView {

    Tab {

        title: "Control Panel"

        SplitView {

            orientation: Qt.Vertical
            anchors.fill: parent

            SplitView {

                Layout.fillWidth: true
                Layout.fillHeight: true

                GroupBox {

                    title: "Camera View"
                    flat: true



                    QNiTETrackerRenderer {
                        id: kinectPreview

                        anchors.centerIn: parent

                        width: 640
                        height: 480

                        kinect: qnite
                        keepHistogram: keepHistogramButton.checked

                        onNewFrameAvailable: {
                            if(updateKinectPreview.checked) kinectPreview.update();
                        }

                        Component.onCompleted: {
                            qnite.initializedChanged.connect(initialize);
                        }

                        Rectangle
                        {
                            visible: !updateKinectPreview.checked
                            anchors.fill: parent
                            color: "#a0000000"

                            Label
                            {
                                text: "(Camera)"
                                anchors.centerIn: parent
                                color: "white"
                            }

                        }

                        Flow {

                            Button
                            {
                                id: updateKinectPreview
                                checked: false
                                checkable: true
                                text: checked? "Camera View Enabled" : "Camera View Disabled"
                            }

                            Button
                            {
                                id: keepHistogramButton
                                checked: true
                                checkable: true
                                text: checked? "Keep Histogram Enabled" : "Keep Histogram Disabled"
                            }
                        }


                    }
                }

                GroupBox {

                    title: "Game View"
                    flat: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ShaderEffect {
                        id: gamePreview
                        property variant src: gameSurface
                        anchors.centerIn: parent

                        width: 640
                        height: width * gameSurface.sourceItem.height/gameSurface.sourceItem.width

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


                        MouseArea
                        {
                            id: interact
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onPositionChanged:
                            {
                                var w = gameContainer.item.width;
                                var h = gameContainer.item.height;
                                if(pressedButtons & Qt.LeftButton) gameContainer.item.updatePlayer(0, w * mouseX/width, h * mouseY/height);
                                if(pressedButtons & Qt.RightButton) gameContainer.item.updatePlayer(1, w * mouseX/width, h * mouseY/height);
                            }
                        }

                        Flow {

                            anchors.fill: parent

                            Button {
                                text: "Next Game"
                                onClicked: {
                                    gameIndex = (gameIndex + 1) % gameList.length
                                    qnite.utilTrimEngineComponentCache()
                                }
                            }

                            Button {
                                text: "Restart Game"
                                onClicked: {
                                    gameContainer.active = false;
                                    qnite.utilTrimEngineComponentCache()
                                    gameContainer.active = true;
                                }

                            }
                        }
                    }

                }
            }

            SplitView {

                GroupBox {

                    title: "Tracker"
                    flat: true

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Row {

                        id: trackerRow
                        anchors.fill: parent

                        spacing: 4

                        ColumnLayout {

                            width: 200

                            Label {
                                id: masterLabel
                                text: "Frame Index: " + qnite.frameIndex
                                font.pointSize: 13
                                font.family: "monospace"
                            }

                            Label {
                                text: "Initialized: " + qnite.initialized
                                font.pointSize: masterLabel.font.pointSize
                                font.family: masterLabel.font.family
                            }

                            Label {
                                text: "Users: " + qnite.userCount
                                font.pointSize: masterLabel.font.pointSize
                                font.family: masterLabel.font.family
                            }

                            Label {
                                text: "Skeletons: " + qnite.skeletonCount
                                font.pointSize: masterLabel.font.pointSize
                                font.family: masterLabel.font.family
                            }
                        }

                        Component.onCompleted: qnite.userFound.connect(userFound)

                        function userFound(uid)
                        {
                            console.log("UserFound");
                            var c = Qt.createComponent("ControlPanelUserDisplay.qml");
                            var o = c.createObject(trackerRow, {userObj: qnite.getUser(uid)});
                        }
                    }
                }

                GroupBox {

                    title: "Menu"
                    flat: true

                    ColumnLayout {
                        width: parent.width


                        Button {
                            text: "Spawn Viewer"
                            onClicked: {
                                controlWindow.spawnViewer();
                            }
                        }


                        Button {
                            text: "Toggle Game Visible"
                            onClicked: {
                                gameSurface.hideSource = ! gameSurface.hideSource
                            }
                        }

                        Button {
                            text: "Quit"
                            onClicked: {
                                Qt.quit();
                            }

                        }
                    }

                }
            }
        }
    }


    Tab {

        title: "About"

        TextArea {
            readOnly: true
            textFormat: TextEdit.RichText
            text: "<html><body>
<h1>
QMLnect
</h1>

<h2>
About
</h2>

<p>
This integration layer allows the integration of Kinect with QML games. Multiple output supported.
</p>

<h2>
Authors
</h2>

<p>
Core by Lucas Camargo.
</p>

</body></html>
"
        }
    }

}

