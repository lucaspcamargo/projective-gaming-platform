import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

GroupBox {

    id: userDisplay

    property var userObj: null
    property int userId: userObj.userId

    title: ("User [%1]").arg(userObj.userId)
    width: 128*1.5
    height: parent.height

    ColumnLayout
    {
        anchors.fill: parent

        Label
        {
            text: userObj.hasSkeleton? "Has Skeleton" : "No skeleton"
            color: userObj.hasSkeleton? "blue" : "darkred"

            font.weight: Font.Bold
        }

        Label
        {
            text: userObj.centerOfMass.x.toFixed(0)+ " " +
                  userObj.centerOfMass.y.toFixed(0)+ " " +
                  userObj.centerOfMass.z.toFixed(0)

            font.weight: Font.Bold
            font.family: "monospace"
        }

    }

    Component.onCompleted: qnite.userLost.connect(userLost)

    function userLost(uid)
    {
        if(uid === userId)
            destroy();
    }
}

