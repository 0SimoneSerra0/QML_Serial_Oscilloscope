import QtQuick
import QtQuick.Controls
import MyModel
import QtQuick.Shapes
import "scripts.js" as Scripts

//Interface under the open/close portbutton, on this it's possible to write
//and read data on the serial port
Item {
    id: root

    property color color: "#000000"
    property color border_color: "#101010"
    property int border_width: 7
    property color text_color: "#dfdfdf"
    property bool auto_scroll_enabled: true

    required property var anchors_mouse_area

<<<<<<< HEAD

=======
>>>>>>> e6d2053 (Added comment and code rearranged)
    //Text on top of the interface
    Rectangle{
        id: recived_label_bg

        x: bg_input.x + bg_input.width/2 - width/2

        width: (recived_label.text.length*recived_label.font.pixelSize/2) + 0.3*height
        height: recived_label.font.pixelSize*1.1
        border.width: 1/60*width
        radius: 10

        color: Qt.rgba(0,0,0,0.3)
        border.color: Qt.darker(root.border_color)

        Text{
            id: recived_label

            anchors.centerIn: parent

            font.pixelSize: bg_input.width/text.length
            color: Qt.lighter(root.text_color)
            text: "Serial Terminal"
        }
    }

    //Writing interface
    Rectangle{
        id: bg_text_input

        y: recived_label_bg.y + recived_label_bg.height*1.1

        width: root.width
        height: 1/9 * root.height

        color: Qt.lighter(root.color)
        TextField{
            id: text_input

            anchors.fill: parent

            clip: true
            color: Qt.lighter(root.text_color)

<<<<<<< HEAD
            onFocusChanged:{
                if(focus){
                    Scripts.createMouseArea(this, root.anchors_mouse_area)
                }else{
                    Scripts.destroyMouseArea()
                }
            }

=======
>>>>>>> e6d2053 (Added comment and code rearranged)
            onAccepted:{
                if(text_input.text === ""){
                    return
                }
                if(Model.writeSerialData(text_input.text)){
                    scroll_view.old_scroll_position = scroll_view.ScrollBar.vertical.position
                    scroll_view.old_content_height = scroll_view.contentHeight

                    //write the sennding data on the text_area among all the
                    //recived one, but the sending data get printed in white/blue
                    text_area.text += "\n<font color=\"#aaaaff\">" + text_input.text + "</font>\n"

                    text_area.textChanged()
                    text_input.clear()
                }
            }
        }
    }

    //reciving interface
    Rectangle {
        id: bg_input

        y: bg_text_input.y + bg_text_input.height

        width: root.width
        height: root.height - y
        border.width: width/100

        border.color: root.border_color
        color: root.color

        //auto scroll button
        Rectangle{
            id: auto_scroll_btn_bg

            y: parent.height

            width: bg_input.width/10
            height: width
            border.width: width/20
            radius: 10

            color: Qt.darker(root.color)
            border.color: Qt.darker(color)
            Shape{
                scale: (auto_scroll_btn_bg.height*8/10)/(path_first_arrow.startY + 2/5*Math.sqrt(3) * auto_scroll_btn_bg.width + auto_scroll_btn_bg.width*2/10 + path_second_arrow.strokeWidth)
                anchors.fill: parent

                ShapePath{
                    id: path_first_arrow

                    strokeWidth: auto_scroll_btn_bg.width/10
                    strokeStyle: ShapePath.SolidLine
                    strokeColor: Qt.lighter(root.text_color)
                    fillColor: Qt.rgba(0,0,0,0)

                    startX: auto_scroll_btn_bg.width/10
                    startY: auto_scroll_btn_bg.height/10
                    PathLine{x: auto_scroll_btn_bg.width*5/10; y: path_first_arrow.startY + 2/5*Math.sqrt(3) * auto_scroll_btn_bg.width}
                    PathLine{x: auto_scroll_btn_bg.width*9/10; y: auto_scroll_btn_bg.height/10}
                }

                ShapePath{
                    id: path_second_arrow

                    strokeWidth: auto_scroll_btn_bg.width/10
                    strokeStyle: ShapePath.SolidLine
                    strokeColor: Qt.lighter(root.text_color)
                    fillColor: Qt.rgba(0,0,0,0)

                    startX: auto_scroll_btn_bg.width/10
                    startY: auto_scroll_btn_bg.height/10 + auto_scroll_btn_bg.width*2/10 + strokeWidth
                    PathLine{x: auto_scroll_btn_bg.width*5/10; y: path_first_arrow.startY + 2/5*Math.sqrt(3) * auto_scroll_btn_bg.width + auto_scroll_btn_bg.width*2/10 + path_second_arrow.strokeWidth}
                    PathLine{x: auto_scroll_btn_bg.width*9/10; y: path_second_arrow.startY}
                }
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    text_area.auto_scroll = !text_area.auto_scroll
                    if(text_area.auto_scroll){
                        path_first_arrow.strokeColor = Qt.lighter(root.text_color)
                        path_second_arrow.strokeColor = Qt.lighter(root.text_color)
                        auto_scroll_btn_bg.color = Qt.lighter(auto_scroll_btn_bg.color)
                        auto_scroll_btn_bg.border.color = Qt.lighter(auto_scroll_btn_bg.border.color)
                    }else{
                        path_first_arrow.strokeColor = root.text_color
                        path_second_arrow.strokeColor = root.text_color
                        auto_scroll_btn_bg.color = Qt.darker(root.color)
                        auto_scroll_btn_bg.border.color = Qt.darker(auto_scroll_btn_bg.color)
                    }
                }
            }
        }

        ScrollView{
            id: scroll_view

            property real old_scroll_position
            property real old_content_height

            x: bg_input.border.width
            y: bg_input.border.width

<<<<<<< HEAD
            width: parent.width
=======
            width: parent.width//bg_input.width - bg_input.border.width*2
>>>>>>> e6d2053 (Added comment and code rearranged)
            height: bg_input.height - bg_input.border.width*2

            contentWidth: bg_input.width
            contentHeight: text_area.height
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            TextArea{
                id: text_area
<<<<<<< HEAD
                property int max_text_length: 4000
=======
>>>>>>> e6d2053 (Added comment and code rearranged)

                property bool auto_scroll: true

                anchors.fill: parent

                textFormat: TextEdit.RichText
                color: root.text_color
                wrapMode: Text.WrapAnywhere
                readOnly: true
                text: ""

<<<<<<< HEAD
                onFocusChanged:{
                    if(focus){
                        Scripts.createMouseArea(this, root.anchors_mouse_area)
                    }else{
                        Scripts.destroyMouseArea()
                    }
                }

=======
>>>>>>> e6d2053 (Added comment and code rearranged)
                onTextChanged:{
                    if(text_area.auto_scroll){
                        scroll_view.ScrollBar.vertical.position = scroll_view.contentHeight >= scroll_view.height ? 1 - scroll_view.height/scroll_view.contentHeight : 0
                    }else{
                        scroll_view.ScrollBar.vertical.position = scroll_view.old_scroll_position * scroll_view.old_content_height/scroll_view.contentHeight
                    }
                }
            }
        }
    }

    Connections{
        target: Model
        function onAppendSerialData(data){
            scroll_view.old_scroll_position = scroll_view.ScrollBar.vertical.position
            scroll_view.old_content_height = scroll_view.contentHeight
<<<<<<< HEAD
            text_area.append(data)
            if(text_area.text.length > text_area.max_text_length){
                text_area.text = text_area.text.substr(text_area.text.length - text_area.max_text_length, text_area.max_text_length)
                text_area.text = text_area.text.substr(text_area.text.indexOf("£$"))
                text_area.textChanged()
            }
=======
            text_area.text += data
            text_area.textChanged()
>>>>>>> e6d2053 (Added comment and code rearranged)
        }
    }
}
