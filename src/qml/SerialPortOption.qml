import QtQuick
import QtQuick.Controls
import MyModel

//Contains all the controls on the left of the program
Item {
    id: root

    property color text_color: "#afafaf"
    property color bg_color: "#afafaf"
    property color bg_border_color: Qt.darker(bg_color)
    property real bg_border_width

    required property var anchors_mouse_area

    Item{
        id: serial_port_option

        height: childrenRect.height

        //selected port option
        Rectangle{
            id: label_selected_port_bg

            width: label_selected_port.width*1.1
            height: label_selected_port.font.pixelSize*1.7
            border.width: root.bg_border_width
            radius: 10

            color: root.bg_color
            border.color: root.bg_border_color


            Label{
                id: label_selected_port

                anchors.centerIn: parent

                color: root.text_color
                font.pixelSize: 1/18 * root.width
                font.bold: true
                text: "Selected port:  "
            }
            ComboBox{
                id: combo_box_selected_port

                anchors.left: parent.right
                anchors.verticalCenter: label_selected_port.verticalCenter

                width: root.width - x*1.02
                height: label_selected_port_bg.height

                model: Model.getAllAvailablePortName()
                onCurrentIndexChanged:{
                    Model.changePort(currentIndex)
                }

                onDownChanged:{
                    if(!down)
                        return
                    var open_port = Model.isPortOpen()
                    currentIndex = Model.getAllAvailablePortName().indexOf(valueAt(currentIndex))
                    model = Model.getAllAvailablePortName()
                    currentIndexChanged()
                    Model.openClosePort(open_port)
                }
            }
        }

        //baud rate options
        Rectangle{
            id: label_baud_rate_bg

            y: label_selected_port_bg.y + label_baud_rate_bg.height * 1.1

            width: label_baud_rate.width*1.1
            height: label_baud_rate.font.pixelSize*1.7
            border.width: root.bg_border_width
            radius: 10

            color: root.bg_color
            border.color: root.bg_border_color

            Label{
                id: label_baud_rate

                anchors.centerIn: parent

                color: root.text_color
                font.pixelSize: 1/18 * root.width
                font.bold: true
                text: "Baud Rate: "
            }
            ComboBox{
                id: combo_box_baud_rate

                x: combo_box_selected_port.x
                anchors.verticalCenter: label_baud_rate.verticalCenter

                width: root.width - x*1.02
                height: label_baud_rate_bg.height

                model: Model.getCommonBaudRates();
                currentIndex: 6

                onCurrentIndexChanged:{
                    model.changeBaudRate(currentIndex)
                }
            }
        }

        // data bits options
        Rectangle{
            id: label_data_bits_bg

            y: label_baud_rate_bg.y + label_baud_rate_bg.height * 1.1

            width: label_data_bits.width*1.1
            height: label_data_bits.font.pixelSize*1.7
            border.width: root.bg_border_width
            radius: 10

            color: root.bg_color
            border.color: root.bg_border_color

            Label{
                id: label_data_bits

                anchors.centerIn: parent

                color: root.text_color
                font.pixelSize: 1/18 * root.width
                font.bold: true
                text: "Data bits: "
            }
            SpinBox{
                id: combo_box_data_bits

                x: combo_box_baud_rate.x
                anchors.verticalCenter: label_data_bits.verticalCenter

                width: root.width - x*1.02
                height: label_data_bits_bg.height

                from: 5
                to: 8
                value: 8

                onValueChanged:{
                    Model.changeDataBits(value)
                }
            }
        }

        //parity options
        Rectangle{
            id: label_parity_bg

            y: label_data_bits_bg.y + label_data_bits_bg.height * 1.1

            width: label_parity.width*1.1
            height: label_parity.font.pixelSize*1.7
            border.width: root.bg_border_width
            radius: 10

            color: root.bg_color
            border.color: root.bg_border_color

            Label{
                id: label_parity

                anchors.centerIn: parent

                color: root.text_color
                font.pixelSize: 1/18 * root.width
                font.bold: true
                text: "Parity: "
            }
            ComboBox{
                id: combo_box_parity

                x: combo_box_data_bits.x
                anchors.verticalCenter: label_parity.verticalCenter

                width: root.width - x*1.02
                height: label_parity_bg.height

                model: Model.getPossibleParity();

                onCurrentIndexChanged:{
                    Model.changeParity(currentIndex)
                }
            }
        }

        //stop bits options
        Rectangle{
            id: label_stop_bits_bg

            y: label_parity_bg.y + label_parity_bg.height * 1.1

            width: label_stop_bit.width*1.1
            height: label_stop_bit.font.pixelSize*1.7
            border.width: root.bg_border_width
            radius: 10

            color: root.bg_color
            border.color: root.bg_border_color



            Label{
                id: label_stop_bit

                anchors.centerIn: parent

                color: root.text_color
                font.pixelSize: 1/18 * root.width
                font.bold: true
                text: "Stop bits: "
            }
            ComboBox{
                id: combo_box_stop_bits

                x: combo_box_parity.x
                anchors.verticalCenter: label_stop_bits_bg.verticalCenter

                width: root.width - x*1.02
                height: label_stop_bits_bg.height
                model: Model.getPossibleStopBits();

                onCurrentIndexChanged:{
                    Model.changeStopBits(currentIndex)
                }
            }
        }

        //flow control options
        Rectangle{
            id: label_flow_control_bg

            y: label_stop_bits_bg.y + label_stop_bits_bg.height * 1.1

            width: label_flow_cotrol.width*1.1
            height: label_flow_cotrol.font.pixelSize*1.7
            border.width: root.bg_border_width
            radius: 10

            color: root.bg_color
            border.color: root.bg_border_color

            Label{
                id: label_flow_cotrol

                anchors.centerIn: parent

                color: root.text_color
                font.pixelSize: 1/18 * root.width
                font.bold: true
                text: "Flow control: "
            }
            ComboBox{
                id: combo_box_flow_control

                x: combo_box_stop_bits.x
                anchors.verticalCenter: label_flow_control_bg.verticalCenter

                width: root.width - x*1.02
                height: label_flow_control_bg.height

                model: Model.getPossibleFlowControls();

                onCurrentIndexChanged:{
                    Model.changeFlowControl(currentIndex)
                }
            }
        }

        // Open/Close options
        Rectangle{
            id: open_and_close_button

            property bool btn_pressed : false
<<<<<<< HEAD
=======
            property bool port_open: Model.isPortOpen()
>>>>>>> e6d2053 (Added comment and code rearranged)

            y: label_flow_control_bg.y + label_flow_control_bg.height * 1.1

            width: root.width
            height: label_open_and_close_button.font.pixelSize*1.7
            border.width: 1/90 * width
            radius:20

            color: root.bg_color
            border.color: root.bg_border_color
<<<<<<< HEAD
=======

            Connections{
                target: Model
                function onPortChanged(port_state){
                    label_open_and_close_button.text = port_state ? "Close Port" : "Open Port"
                    open_and_close_button.port_open = Model.isPortOpen()
                }
            }
>>>>>>> e6d2053 (Added comment and code rearranged)

            Label{
                id: label_open_and_close_button

                anchors.centerIn: parent

                color: root.text_color
                font.pixelSize: 1/17 * root.width
                font.bold: true
<<<<<<< HEAD
                text: Model.isPortOpen() ? "Close Port" : "Open Port"
=======
                text: open_and_close_button.port_open ? "Close Port" : "Open Port"
>>>>>>> e6d2053 (Added comment and code rearranged)
            }
            MouseArea{
                id: mouse_area_open_and_close_button

                anchors.fill: parent

                onPressed:{
                    open_and_close_button.btn_pressed = true
                    open_and_close_button.color = Qt.darker(open_and_close_button.color)
                    open_and_close_button.border.color = Qt.darker(open_and_close_button.border.color)
                    label_open_and_close_button.color = Qt.darker(label_open_and_close_button.color)
                }
                onExited:{
                    if(open_and_close_button.btn_pressed){
                        open_and_close_button.btn_pressed = false
                        open_and_close_button.color = root.bg_color
                        open_and_close_button.border.color = root.bg_border_color
                        label_open_and_close_button.color = root.text_color
                    }
                }

                onReleased: {
                    if(open_and_close_button.btn_pressed){
                        open_and_close_button.color = Qt.darker(label_flow_cotrol.color)
                        label_open_and_close_button.color = "#afafaf"
                        if(Model.openClosePort(!Model.isPortOpen())){
                            label_open_and_close_button.text = Model.isPortOpen() ? "Close Port" : "Open Port"
                        }
                    }
                }
            }
        }
    }

    SerialIOInterface{
        id: serial_io_interface

        y: serial_port_option.height + root.width/30

        width: root.width
        height: (2/3) * root.width

        text_color: root.text_color
        color: root.bg_color
        border_color: root.bg_color

        anchors_mouse_area: root.anchors_mouse_area
    }


    ErrorTerminal{
        id: error_terminal

        x: (root.width - width)/2
        y: serial_io_interface.y + serial_io_interface.height + (root.height - serial_io_interface.y - serial_io_interface.height - height)/2

        width: root.width*0.9
        height: (1.5/3) * width
    }

    Connections{
        target: Model
        function onPortStateChanged(port_state){
            label_open_and_close_button.text = port_state ? "Close Port" : "Open Port"
        }
    }
}
