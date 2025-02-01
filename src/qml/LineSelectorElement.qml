import QtQuick
import QtQuick.Layouts
import MyModel


//is the litle selectble rectangle in the rowLayout just under the graph, when there is a
//series to plot
Item {
    id: root

    property color bg_color: "#303030"
    property color line_color
    property color text_color
    property string line_name

    Layout.fillWidth: true
    Layout.fillHeight: true

    function remove(){
        destroy()
    }

    Rectangle{
        id: color_circle

        width: height
        height: root.height
        radius: width*0.5

        color: root.line_color
    }

    Rectangle{
        id: bg

        x: color_circle.width

        height: root.height
        width: root.width - color_circle.width
        radius: width/20

        color: root.bg_color

        Text{
            id: text

            x: (bg.width - width)/2
            y: (bg.height - height)/2

            font.pointSize: bg.height*0.8

            color: root.text_color
            text: root.line_name
        }
    }

    MouseArea{
        anchors.fill: root

        onClicked:{
            if(Model.getSelectedLine() === root.line_name){
                Model.setSelectedLine("")

                bg.color = root.bg_color
                color_circle.color = root.line_color
                text.color = root.text_color
            }else{
                Model.setSelectedLine(root.line_name)

                bg.color = Qt.darker(root.bg_color)
                color_circle.color = Qt.darker(root.line_color)
                text.color = Qt.darker(root.text_color)
            }
        }
    }

    Connections{
        target: Model
        function onSelectedLineChanged(){
            if(Model.getSelectedLine() !== root.line_name){
                bg.color = root.bg_color
                color_circle.color = root.line_color
                text.color = root.text_color
            }
        }
    }
}
