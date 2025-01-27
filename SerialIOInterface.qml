import QtQuick
import QtQuick.Controls
import MyModel
import QtQuick.Shapes


Item {
    id: root
    property color color: "#000000"
    property color border_color: "#101010"
    property int border_width: 7
    property color text_color: "#dfdfdf"
    property bool auto_scroll_enabled: true


    Rectangle{
        id: recived_label_bg
        x: bg_input.x + bg_input.width/2 - width/2
        width: (recived_label.text.length*recived_label.font.pixelSize/2) + 0.3*height
        height: recived_label.font.pixelSize*1.1
        color: Qt.rgba(0,0,0,0.3)
        radius: 10
        border.color: Qt.darker(root.border_color)
        border.width: 1/60*width

        Text{
            anchors.centerIn: parent
            id: recived_label
            text: "Serial Terminal"
            font.pixelSize: bg_input.width/text.length
            color: Qt.lighter(root.text_color)
        }
    }

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
            onAccepted:{
                if(text_input.text === ""){
                    return
                }
                if(Model.writeSerialData(text_input.text)){
                    scroll_view.old_scroll_position = scroll_view.ScrollBar.vertical.position
                    scroll_view.old_content_height = scroll_view.contentHeight
                    text_area.text += "\n<font color=\"#dddddd\">" + text_input.text + "</font>\n"
                    text_area.textChanged()
                    text_input.clear()
                }
            }
        }
    }
    Rectangle {
        id: bg_input
        width: root.width
        y: bg_text_input.y + bg_text_input.height
        height: root.height - y
        border.color: root.border_color
        border.width: width/100
        color: root.color

        Rectangle{
            id: auto_scroll_btn_bg
            y: parent.height
            width: bg_input.width/10
            height: width
            color: Qt.darker(root.color)
            border.color: Qt.darker(color)
            border.width: width/20
            radius: 10
            Shape{
                scale: (auto_scroll_btn_bg.height*8/10)/(path_first_arrow.startY + 2/5*Math.sqrt(3) * auto_scroll_btn_bg.width + auto_scroll_btn_bg.width*2/10 + path_second_arrow.strokeWidth)
                anchors.fill: parent

                ShapePath{
                    id: path_first_arrow
                    strokeWidth: auto_scroll_btn_bg.width/10
                    strokeColor: Qt.lighter(root.text_color)
                    strokeStyle: ShapePath.SolidLine
                    fillColor: Qt.rgba(0,0,0,0)
                    startX: auto_scroll_btn_bg.width/10
                    startY: auto_scroll_btn_bg.height/10
                    PathLine{x: auto_scroll_btn_bg.width*5/10; y: path_first_arrow.startY + 2/5*Math.sqrt(3) * auto_scroll_btn_bg.width}
                    PathLine{x: auto_scroll_btn_bg.width*9/10; y: auto_scroll_btn_bg.height/10}
                }

                ShapePath{
                    id: path_second_arrow
                    strokeWidth: auto_scroll_btn_bg.width/10
                    strokeColor: Qt.lighter(root.text_color)
                    strokeStyle: ShapePath.SolidLine
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
            property real old_scroll_position
            property real old_content_height
            id: scroll_view
            x: bg_input.border.width
            y: bg_input.border.width
            width: parent.width//bg_input.width - bg_input.border.width*2
            height: bg_input.height - bg_input.border.width*2
            contentWidth: bg_input.width
            contentHeight: text_area.height
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            TextArea{
                property bool auto_scroll: true
                id: text_area
                anchors.fill: parent
                text: ""
                color: root.text_color
                textFormat: TextEdit.RichText
                wrapMode: Text.WrapAnywhere
                readOnly: true
                onTextChanged:{
                    if(text_area.auto_scroll){
                        scroll_view.ScrollBar.vertical.position = scroll_view.contentHeight >= scroll_view.height ? 1 - scroll_view.height/scroll_view.contentHeight : 0
                    }else{
                        scroll_view.ScrollBar.vertical.position = scroll_view.old_scroll_position * scroll_view.old_content_height/scroll_view.contentHeight
                    }
                }
            }
            Connections{
                target: Model
                function onAppendSerialData(data){
                    scroll_view.old_scroll_position = scroll_view.ScrollBar.vertical.position
                    scroll_view.old_content_height = scroll_view.contentHeight
                    text_area.text += data
                    text_area.textChanged()
                }
            }
        }
    }
}
