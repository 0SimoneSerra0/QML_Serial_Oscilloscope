import QtQuick
import QtQuick.Controls
import MyModel

Item {
    id: root
    property color text_color: "#afafaf"
    property color bg_color: "#afafaf"
    property color bg_border_color: Qt.darker(bg_color)
    property real bg_border_width

    Item{
        id: serial_port_option
        height: childrenRect.height

        Rectangle{
            id: label_selected_port_bg
            width: label_selected_port.width*1.1
            height: label_selected_port.font.pixelSize*1.7
            color: root.bg_color
            border.color: root.bg_border_color
            border.width: root.bg_border_width
            radius: 10


            Label{
                id: label_selected_port
                anchors.centerIn: parent
                color: root.text_color
                text: "Selected port:  "
                font.pixelSize: 1/18 * root.width
                font.bold: true
            }
            ComboBox{
                id: combo_box_selected_port
                width: root.width - x*1.02
                height: label_selected_port_bg.height
                model: Model.getAllAvailablePortName()
                anchors.left: parent.right
                anchors.verticalCenter: label_selected_port.verticalCenter
                onCurrentIndexChanged:{
                    Model.changePort(currentIndex)
                }
                onFocusChanged:{
                    model = Model.getAllAvailablePortName()
                }
            }
        }

        Rectangle{
            id: label_baud_rate_bg
            width: label_baud_rate.width*1.1
            height: label_baud_rate.font.pixelSize*1.7
            color: root.bg_color
            border.color: root.bg_border_color
            border.width: root.bg_border_width
            radius: 10

            y: label_selected_port_bg.y + label_baud_rate_bg.height * 1.1


            Label{
                id: label_baud_rate
                anchors.centerIn: parent
                color: root.text_color
                text: "Baud Rate: "
                font.pixelSize: 1/18 * root.width
                font.bold: true
            }
            ComboBox{
                id: combo_box_baud_rate
                x: combo_box_selected_port.x
                width: root.width - x*1.02
                height: label_baud_rate_bg.height
                model: Model.getCommonBaudRates();
                anchors.verticalCenter: label_baud_rate.verticalCenter
                currentIndex: 6

                onCurrentIndexChanged:{
                    model.changeBaudRate(currentIndex)
                }
            }
        }

        Rectangle{
            id: label_data_bits_bg
            width: label_data_bits.width*1.1
            height: label_data_bits.font.pixelSize*1.7
            color: root.bg_color
            border.color: root.bg_border_color
            border.width: root.bg_border_width
            radius: 10

            y: label_baud_rate_bg.y + label_baud_rate_bg.height * 1.1


            Label{
                id: label_data_bits
                anchors.centerIn: parent
                color: root.text_color
                text: "Data bits: "
                font.pixelSize: 1/18 * root.width
                font.bold: true
            }
            SpinBox{
                id: combo_box_data_bits
                x: combo_box_baud_rate.x
                width: root.width - x*1.02
                height: label_data_bits_bg.height
                from: 5
                to: 8
                value: 8

                anchors.verticalCenter: label_data_bits.verticalCenter

                onValueChanged:{
                    Model.changeDataBits(value)
                }
            }
        }

        Rectangle{
            id: label_parity_bg
            width: label_parity.width*1.1
            height: label_parity.font.pixelSize*1.7
            color: root.bg_color
            border.color: root.bg_border_color
            border.width: root.bg_border_width
            radius: 10

            y: label_data_bits_bg.y + label_data_bits_bg.height * 1.1


            Label{
                id: label_parity
                anchors.centerIn: parent
                color: root.text_color
                text: "Parity: "
                font.pixelSize: 1/18 * root.width
                font.bold: true
            }
            ComboBox{
                id: combo_box_parity
                x: combo_box_data_bits.x
                width: root.width - x*1.02
                height: label_parity_bg.height
                model: Model.getPossibleParity();
                anchors.verticalCenter: label_parity.verticalCenter

                onCurrentIndexChanged:{
                    Model.changeParity(currentIndex)
                }
            }
        }

        Rectangle{
            id: label_stop_bits_bg
            width: label_stop_bit.width*1.1
            height: label_stop_bit.font.pixelSize*1.7
            color: root.bg_color
            border.color: root.bg_border_color
            border.width: root.bg_border_width
            radius: 10

            y: label_parity_bg.y + label_parity_bg.height * 1.1


            Label{
                id: label_stop_bit
                anchors.centerIn: parent
                color: root.text_color
                text: "Stop bits: "
                font.pixelSize: 1/18 * root.width
                font.bold: true
            }
            ComboBox{
                id: combo_box_stop_bits
                x: combo_box_parity.x
                width: root.width - x*1.02
                height: label_stop_bits_bg.height
                model: Model.getPossibleStopBits();
                anchors.verticalCenter: label_stop_bits_bg.verticalCenter

                onCurrentIndexChanged:{
                    Model.changeStopBits(currentIndex)
                }
            }
        }

        Rectangle{
            id: label_flow_control_bg
            width: label_flow_cotrol.width*1.1
            height: label_flow_cotrol.font.pixelSize*1.7
            color: root.bg_color
            border.color: root.bg_border_color
            border.width: root.bg_border_width
            radius: 10

            y: label_stop_bits_bg.y + label_stop_bits_bg.height * 1.1


            Label{
                id: label_flow_cotrol
                anchors.centerIn: parent
                color: root.text_color
                text: "Flow control: "
                font.pixelSize: 1/18 * root.width
                font.bold: true
            }
            ComboBox{
                id: combo_box_flow_control
                x: combo_box_stop_bits.x
                width: root.width - x*1.02
                height: label_flow_control_bg.height
                model: Model.getPossibleFlowControls();
                anchors.verticalCenter: label_flow_control_bg.verticalCenter

                onCurrentIndexChanged:{
                    Model.changeFlowControl(currentIndex)
                }
            }
        }
        Rectangle{
            id: open_and_close_button
            radius:20
            width: root.width
            height: label_open_and_close_button.font.pixelSize*1.7

            y: label_flow_control_bg.y + label_flow_control_bg.height * 1.1

            property bool port_open: Model.isPortOpen()
            property bool btn_pressed : false
            color: root.bg_color
            border.color: root.bg_border_color
            border.width: 1/90 * width

            Connections{
                target: Model
                function onPortChanged(port_state){
                    label_open_and_close_button.text = port_state ? "Close Port" : "Open Port"
                    open_and_close_button.port_open = Model.isPortOpen()
                }
            }

            Label{
                id: label_open_and_close_button
                anchors.centerIn: parent
                color: root.text_color
                text: open_and_close_button.port_open ? "Close Port" : "Open Port"
                font.pixelSize: 1/17 * root.width
                font.bold: true
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
                        if(Model.openClosePort(!open_and_close_button.port_open)){
                            open_and_close_button.port_open = !open_and_close_button.port_open
                            label_open_and_close_button.text = open_and_close_button.port_open ? "Close Port" : "Open Port"
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
    }


    ErrorTerminal{
        id: error_terminal
        x: (root.width - width)/2
        y: serial_io_interface.y + serial_io_interface.height + (root.height - serial_io_interface.y - serial_io_interface.height - height)/2
        width: root.width*0.9
        height: (1.5/3) * width
    }
}
