import QtQuick
import QtQuick.Controls

pragma ComponentBehavior: Bound;


ComboBox{
    id: root

    property color color: "#434343"
    property color text_color: "#dfdfdf"

    property double max_text_width: 0

    function checkMaxTextWidth(w){
        if(w > max_text_width){
            max_text_width = w
        }
    }

    delegate: ItemDelegate {
        id: del

        required property var model

        contentItem: Text {
            text: "-  " + del.model[root.textRole]

            Component.onCompleted: root.checkMaxTextWidth((width + leftPadding)*1.2)

            color: root.text_color
            font: root.font

            verticalAlignment: Text.AlignVCenter

            leftPadding: del.width/30
        }
        background.opacity: 0
    }

    onPressedChanged:{
        if(pressed){
            bg.color = Qt.darker(root.color)
            bg.border.color = root.color
        }else{
            bg.color = root.color
            bg.border.color = Qt.lighter(root.color)
        }
    }

    contentItem: Text{
        text: root.displayText
        color: root.pressed ? Qt.darker(root.text_color) : root.text_color

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight

        leftPadding: root.width/30

        font.bold: true
    }

    background: Rectangle{
        id: bg
        anchors.fill: root

        border.width: width/200
        radius: width*0.2

        border.color: Qt.lighter(root.color)
        color: root.color
    }

    popup: Popup {
        x: (root.width - width)/2
        y: root.height*1.01

        width: root.max_text_width
        height: Math.min(contentItem.implicitHeight, root.Window.height - topMargin - bottomMargin)
        padding: 1

        contentItem: ListView {
            id: list

            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            border.width: width/200
            radius: 16

            border.color: Qt.lighter(root.color)
            color: root.color
        }
    }
}
