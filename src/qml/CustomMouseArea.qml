import QtQuick
import "scripts.js" as Scripts
//this mouse area is needed for making possible to loose the focus of a TextEdit,
//or other focus-taking object, when the mouse click on another screen point
Item{
    id: root

    anchors.fill: parent

    required property var target

    MouseArea{
        anchors.fill: parent

        propagateComposedEvents: true

        onPressed:{
            target.focus = false
            Scripts.destroyMouseArea()
        }
    }
}
