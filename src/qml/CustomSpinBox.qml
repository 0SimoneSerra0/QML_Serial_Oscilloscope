import QtQuick
import QtQuick.Controls

SpinBox{
    id: root
    property color color: "#434343"

    background: Rectangle{
        id: bg

        anchors.fill: root

        border.width: width/200
        radius: width*0.05

        border.color: Qt.lighter(root.color)
        color: root.color
    }

    up.indicator: Rectangle{
        id: up_ind
        x: bg.width*0.88
        y: root.height/20

        width: bg.height/2.1
        height: width
        radius: width/2

        color: Qt.rgba(0,0,0,0)

        Text{
            id: plus_text
            x: (parent.width - width)/2
            y: (parent.height - height)/2

            text: "+"
            color: "white"

            font.pointSize: parent.width
        }

        MouseArea{
            anchors.fill: parent
            property bool press: false

            onPressed: {
                press = true
                up_ind.color = Qt.lighter(root.color)
            }

            onExited: {
                if(press){
                    press = false
                    up_ind.color = Qt.rgba(0,0,0,0)
                }
            }
            onReleased: {
                if(press){
                    if(root.value + 1 <= root.to){
                        root.value += 1
                    }
                    up_ind.color = Qt.rgba(0,0,0,0)
                    press = false
                }
            }
        }
    }

    down.indicator: Rectangle{
        id: down_ind

        x: up_ind.x
        y: up_ind.height + up_ind.y

        width: up_ind.width
        height: width
        radius: width/2

        color: Qt.rgba(0,0,0,0)

        Text{
            id: minus_text
            x: (parent.width - width)/2
            y: (parent.height - height)/2

            text: "-"
            color: "white"

            font.pointSize: parent.width
        }

        MouseArea{
            anchors.fill: parent
            property bool press: false

            onPressed: {
                press = true
                down_ind.color = Qt.lighter(root.color)
            }

            onExited: {
                if(press){
                    press = false
                    down_ind.color = Qt.rgba(0,0,0,0)
                }
            }
            onReleased: {
                if(press){
                    if(root.value - 1 >= root.from){
                        root.value -= 1
                    }
                    down_ind.color = Qt.rgba(0,0,0,0)
                    press = false
                }
            }
        }
    }

    Component.onCompleted: valueChanged()

    onValueChanged: {
        if(value == to){
            plus_text.color = Qt.darker("white")
        }else{
            plus_text.color = "white"
        }

        if(value == from){
            minus_text.color = Qt.darker("white")
        }else{
            minus_text.color = "white"
        }
    }
}
