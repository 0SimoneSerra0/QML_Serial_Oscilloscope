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

            property var pnt1 : [serial_port_options_bg.width, strokeWidth/2]
            property var pnt2 : [serial_port_options_bg.width, graph_ctrl_container.y]
            property var pnt3 : [root.width,  graph_ctrl_container.y]
            property var pnt4 : [root.width, root.height]
            property var pnt5 : [strokeWidth/2, root.height]
            property var pnt6 : [strokeWidth/2, 0]

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

            width: 1/4.5*root.width
            height: serial_port_options.y + serial_port_options.height + border_width*1.1
            border.width: border_width

            color: Qt.rgba(0,0,0,0)
            border.color: Qt.rgba(0,0,0,0.0)

            //label in the top left
            Rectangle{
                id: serial_port_options_label_bg

                x: (serial_port_options_bg - width)/2
                y: serial_port_options_bg.border_width*1.1

                width: parent.width*0.95
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
                x: serial_port_options_bg.x
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

    Graph{
        id: graph

        x: serial_port_options_bg.x + serial_port_options_bg.width

        width: root.width - x
        height: graph_ctrl_container.y
    }

    //control under the graph
    Item{
        id: graph_ctrl_container
        property double last_height

        Component.onCompleted: last_height = height

        x: graph.x
        y: root.height - height + shape.strokeWidth*2

        width: root.width - x
        height: root.height/2.7

        GraphControls{
            id: graph_controls
            width: parent.width
            height: parent.height
            anchors_mouse_area: anchors_for_mouse_area
        }
    }


    Rectangle{
        id: bg_hide_serial_port_options_btn

        x: serial_port_options_bg.x + serial_port_options_bg.width
        y: root.height - height

        width: root.width/30
        height: width*0.50

        color: "#202020"

        MouseArea{
            id: mouse_area_show_hide_serial_port_options_ctrls
            anchors.fill: parent

            property bool options_hided: false

            onClicked:{
                if(!options_hided){
                    show_serial_port_animation.running = false
                    hide_serial_port_animation.running = true
                    options_hided = true
                }else{
                    hide_serial_port_animation.running = false
                    show_serial_port_animation.running = true
                    options_hided = false
                }
            }

            PropertyAnimation{
                id: hide_serial_port_animation
                target: serial_port_options_bg
                property: "x"
                to: -serial_port_options_bg.width
                duration: 500
            }

            PropertyAnimation{
                id: show_serial_port_animation
                target: serial_port_options_bg
                property: "x"
                to: shape.strokeWidth/2
                duration: 500
            }
        }
    }
    //Hide graphs controls Button
    Rectangle{
        id: bg_hide_ctrls_btn

        x: bg_hide_serial_port_options_btn.x + bg_hide_serial_port_options_btn.width*1.1
        y: root.height - height

        width: root.width/30
        height: width*0.50

        color: "#202020"
        MouseArea{
            id: mouse_area_show_hide_graph_ctrls
            anchors.fill: parent

            property bool ctrls_hided: false

            onClicked:{
                if(!ctrls_hided){
                    show_ctrls_animation.running = false
                    hide_ctrls_animation.running = true
                    ctrls_hided = true
                }else{
                    hide_ctrls_animation.running = false
                    show_ctrls_animation.running = true
                    ctrls_hided = false
                }
            }

            PropertyAnimation{
                id: hide_ctrls_animation
                target: graph_ctrl_container
                property: "y"
                to: root.height
                duration: 500
            }

            PropertyAnimation{
                id: show_ctrls_animation
                target: graph_ctrl_container
                property: "y"
                to: root.height - graph_ctrl_container.height + shape.strokeWidth*3
                duration: 500
            }
        }
    }




    //Item that will be the parent of the dynamically creted mouse area
    //used for deselecting the focus from a spin box or a text edit
    Item{
        id: anchors_for_mouse_area

        width: root.width
        height: root.height
    }
}

