import QtQuick

Item {
    id: root

    property double txt_x
    property double txt_y

    Rectangle{
        color: "black"
        opacity: 0.7
        width: x_text.text.length > y_text.text.length ? x_text.text.length*x_text.font.pointSize : y_text.text.length*y_text.font.pointSize
        height: x_text.font.pointSize*2
        Text{
            id: x_text
            text: "X: " + String(root.txt_x)
            color: "#ffffff"
            font.pointSize: 16
        }
        Text{
            id: y_text
            text: "Y: " + String(root.txt_y)
            color: "#ffffff"
            font.pointSize: 16
            x: x_text.x
            y: x_text.y + x_text.font.pointSize
        }
    }
}
