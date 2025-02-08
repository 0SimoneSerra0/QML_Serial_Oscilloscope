import QtQuick
import QtQuick.Controls

TextField {
    id: root
    property color color: "#434343"

    background: Rectangle{
        border.width: width/200
        radius: width*0.009

        border.color: Qt.lighter(root.color)
        color: root.color
    }
}
