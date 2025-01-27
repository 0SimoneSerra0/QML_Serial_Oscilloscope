import QtQuick
import QtQuick.Controls
import MyModel

//terminal in te bottom left, it contains the error messages sent from the Model
Item {
    id: root
    property color color: "#000000"
    property color border_color: "#101010"
    property int border_width: 7
    property color text_color: "#dfdfdf"


    Rectangle {
        id: bg

        width: parent.width
        height: parent.height
        border.width: width/70
        radius: width/10

        color: root.color
        border.color: parent.border_color

        ScrollView {
            id: scroll_view

            x: bg.border.width * 1.5
            y: bg.border.width * 1.5

            height: bg.height - y*2
            width: bg.width - x*2

            clip: true
            contentWidth: -1

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            Text {
                id: output_text
                anchors.fill: parent
                text: ""
                color: root.text_color
                wrapMode: Text.Wrap
            }
        }
    }

    Connections{
        target: Model
        function onEmitAddText(new_text){
            output_text.text = output_text.text + new_text + "\n\n\n"
            scroll_view.ScrollBar.vertical.position = scroll_view.contentHeight >= scroll_view.height ? 1 - scroll_view.height/scroll_view.contentHeight : 0
        }
    }
}
