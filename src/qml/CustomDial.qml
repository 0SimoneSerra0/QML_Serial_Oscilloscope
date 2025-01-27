import QtQuick
import QtQuick.Controls

<<<<<<< HEAD
=======

>>>>>>> e6d2053 (Added comment and code rearranged)
//Custom dial used in GraphControls
Dial{
    id: root

    property color bg_color: "#202020"
    property color pointer_color: "white"

    stepSize: 1

    background: Rectangle {

        x: root.width / 2 - width / 2
        y: root.height / 2 - height / 2

        implicitWidth: 50
        implicitHeight: 50
        width: Math.max(64, Math.min(root.width, root.height))
        height: width
        radius: width / 2
        border.width: width/7

        color: root.bg_color
        border.color: Qt.lighter(color)
    }

    handle: Rectangle {
        id: handleItem

        x: root.background.x + root.background.width / 2 - width / 2
        y: root.background.y + root.background.height / 2 - height / 2
        width: height/4

        height: root.background.width/2
        radius: width*2.5

        color: Qt.darker(root.bg_color)

        antialiasing: true

        Rectangle{
            id: marker

            y: parent.height/10
            x: parent.width/2 - width/2

            width: parent.width*3/5
            height: width
            radius: width/2

            color: root.pointer_color
        }
        transform: [
            Translate {
                y: -Math.min(root.background.width, root.background.height) * 0.4 + handleItem.height / 2
            },
            Rotation {
                angle: root.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]
    }
}
