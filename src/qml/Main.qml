import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import "scripts.js" as Scripts

Window {
    id: root

    minimumWidth: 848
    minimumHeight: 480

    visible: true
    title: "Oscilloscope"
    color: shape.strokeColor

    Graph{
        id: graph
        width: (13/17)*root.width
        height: (1/2)*width
        x: root.width - width
    }

    //BackGround
    Shape {
        id: cotrol_panel_bg
        width: root.width
        height: root.height
        x: 0
        y: 0
        ShapePath {
            id:shape
            strokeWidth: (1/130)*cotrol_panel_bg.width
            strokeColor: Qt.darker(graph.color)
            fillColor: "#2f2f2f"
            strokeStyle: ShapePath.RoundJoin

            property var pnt1 : [root.width - graph.width - strokeWidth/2, 0 + strokeWidth/2]
            property var pnt2 : [root.width - graph.width - strokeWidth/2, graph.height + strokeWidth/2]
            property var pnt3 : [root.width - strokeWidth/2,  graph.height + strokeWidth/2]
            property var pnt4 : [root.width - strokeWidth/2, root.height - strokeWidth/2]
            property var pnt5 : [strokeWidth/2, root.height - shape.strokeWidth/2]
            property var pnt6 : [strokeWidth/2, strokeWidth/2]

            fillGradient: LinearGradient {
                x1: shape.startX; y1: shape.startY
                x2: shape.startX + (root.width - shape.strokeWidth/2); y2: root.height - (root.height - shape.strokeWidth/2)/15
                GradientStop { position: 0; color:  shape.fillColor}
                GradientStop { position: 0.5; color:  Qt.lighter(shape.fillColor)}
                GradientStop { position: 1; color: shape.fillColor }
            }

            startX: 0; startY: shape.strokeWidth/2
            PathLine { x: shape.pnt1[0]; y: shape.pnt1[1] }
            PathLine { x: shape.pnt2[0]; y: shape.pnt2[1] }
            PathLine { x: shape.pnt3[0]; y: shape.pnt3[1] }
            PathLine { x: shape.pnt4[0]; y: shape.pnt4[1] }
            PathLine { x: shape.pnt5[0]; y: shape.pnt5[1] }
            PathLine { x: shape.pnt6[0]; y: shape.pnt6[1] }
        }

        //Left side of the oscilloscope (Serial port option)
        Rectangle{
            id: serial_port_options_bg

            property real border_width: (shape.pnt2[0] - shape.strokeWidth)/50

            x: shape.strokeWidth/2
            y: shape.strokeWidth/2

            width: shape.pnt2[0] - x - border_width*0.1
            height: serial_port_options.y + serial_port_options.height + border_width*1.1
            border.width: border_width

            color: Qt.rgba(0,0,0,0)
            border.color: Qt.rgba(0,0,0,0.4)

            //label in the top left
            Rectangle{
                id: serial_port_options_label_bg

                anchors.horizontalCenter: parent.horizontalCenter
                y: serial_port_options_bg.border_width*1.1

                width: shape.pnt2[0] - shape.strokeWidth - parent.x*2 - serial_port_options_bg.border_width*0.1
                height: 1/7 * width
                border.width: 1/90 * width

                color: "#505050"
                border.color: "#202020"

                Label{
                    id: serial_port_option_label
                    text: "SERIAL PORT OPTIONS"
                    font.pixelSize: serial_port_options_label_bg.width/text.length
                    font.family: "Garamond"
                    font.bold: true
                    anchors.centerIn: serial_port_options_label_bg
                    color: "#bbbbbb"
                }
            }


            SerialPortOption{
                id: serial_port_options
                x: serial_port_options_label_bg.x
                y: serial_port_options_label_bg.y + serial_port_options_label_bg.height + root.height/60

                width: shape.pnt2[0] - shape.strokeWidth - x - serial_port_options_bg.border_width*0.1
                height: root.height - shape.strokeWidth
                text_color: "#bfbfbf"
                bg_color: "#424242"
                bg_border_color: "#101010"
                bg_border_width: width/200

                anchors_mouse_area: anchors_for_mouse_area
            }
        }
    }

    //control under the graph
    GraphControls{
        id: graph_controls

        x: graph.x
        y: shape.pnt2[1] + shape.strokeWidth/2

        width: root.width - x
        height: root.height - y

        anchors_mouse_area: anchors_for_mouse_area
    }

    Item{
        id: anchors_for_mouse_area

        width: root.width
        height: root.height
    }
}

