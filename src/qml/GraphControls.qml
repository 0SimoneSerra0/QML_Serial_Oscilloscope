import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import MyModel
import "scripts.js" as Scripts

//Control panel found at the bottom of the graph
Item {
    id:root

    property color text_color: "white"
    property color bg_color: "#202020"
    property color dial_pointer_color: "white"
    property color bg_text_color: "#303030"

    required property var anchors_mouse_area


    //X zoom controls
    CustomDial {
        id: dial_x_axis

        x: (label_zoom_y_axis_bg.width - width)/2
        y: (root.height - height)/4

        width: root.width/15
        height: width

        bg_color: root.bg_color
        pointer_color: root.dial_pointer_color

        from: Model.getZoomLimits()[0]
        to: Model.getZoomLimits()[1]
        stepSize: 1
        value: 0

        onMoved:{
            spin_box_x_axis.value = dial_x_axis.value
            Model.changeXZoom(dial_x_axis.value);
        }

        Rectangle{
            id: label_zoom_x_axis_bg

            anchors.horizontalCenter: dial_x_axis.horizontalCenter
            y: -dial_x_axis.y

            width: label_zoom_x_axis.text.length*label_zoom_x_axis.font.pointSize
            height: label_zoom_x_axis.font.pointSize*2

            border.color: Qt.darker(color)
            border.width: height/7

            color: root.bg_text_color
            Label{
                id: label_zoom_x_axis
                anchors.centerIn: parent

                color: root.text_color

                text: "Zoom X Axis"
                font.pointSize: dial_x_axis.width/6
                font.bold: true
            }
        }

        SpinBox{
            id: spin_box_x_axis

            anchors.horizontalCenter: dial_x_axis.horizontalCenter
            anchors.top: dial_x_axis.bottom

            width: dial_x_axis.width

            from: dial_x_axis.from
            to: dial_x_axis.to
            stepSize: dial_x_axis.stepSize
            value: dial_x_axis.value

            editable: true

            onFocusChanged:{
                if(focus){
                    Scripts.createMouseArea(this, root.anchors_mouse_area)
                }else{
                    Scripts.destroyMouseArea()
                }
            }

            onValueChanged:{
                dial_x_axis.value = spin_box_x_axis.value
                Model.changeXZoom(dial_x_axis.value);
            }
            Text{
                text: "%"
                anchors.left: parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: parent.height/2
                color: "white"
            }
        }
    }


    //Y zoom controls
    CustomDial {
        id: dial_y_axis

        x: dial_x_axis.x + label_zoom_x_axis_bg.width + label_zoom_y_axis_bg.width/2
        y: dial_x_axis.y

        bg_color: root.bg_color
        pointer_color: root.dial_pointer_color

        width: root.width/15
        height: width

        from: Model.getZoomLimits()[0]
        to: Model.getZoomLimits()[1]
        stepSize: 10
        value: 0

        onMoved:{
            spin_box_y_axis.value = dial_y_axis.value
            Model.changeYZoom(dial_y_axis.value);
        }

        Rectangle{
            id: label_zoom_y_axis_bg
            anchors.horizontalCenter: dial_y_axis.horizontalCenter

            y: -dial_y_axis.y

            width: label_zoom_y_axis.text.length*label_zoom_y_axis.font.pointSize
            height: label_zoom_y_axis.font.pointSize*2

            border.color: Qt.darker(color)
            border.width: height/7

            color: root.bg_text_color
            Label{
                id: label_zoom_y_axis
                anchors.centerIn: parent

                color: root.text_color

                text: "Zoom Y Axis"
                font.pointSize: dial_y_axis.width/6
                font.bold: true
            }
        }

        SpinBox{
            id: spin_box_y_axis

            anchors.horizontalCenter: dial_y_axis.horizontalCenter
            anchors.top: dial_y_axis.bottom

            width: dial_y_axis.width

            from: dial_y_axis.from
            to: dial_y_axis.to
            stepSize: dial_y_axis.stepSize
            value: dial_y_axis.value

            editable: true

            onFocusChanged:{
                if(focus){
                    Scripts.createMouseArea(this, root.anchors_mouse_area)
                }else{
                    Scripts.destroyMouseArea()
                }
            }

            onValueChanged:{
                dial_y_axis.value = spin_box_y_axis.value
                Model.changeYZoom(dial_y_axis.value);
            }
            Text{
                text: "%"
                anchors.left: parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: parent.height/2
                color: "white"
            }
        }
    }

    Text{
        id: shortcut_label

        y: root.height*0.9 - height
        font.pointSize: dial_x_axis.width/7
        color: Qt.darker(root.text_color)
        text: "Ctrl + plus  ->  Zoom In\nCtrl + minus  ->  Zoom Out"
    }

    //Go To Origin button
    Rectangle{
        id: go_to_origin_btn

        x: dial_y_axis.x + dial_y_axis.width + (root.width - dial_y_axis.x)/10
        y: dial_y_axis.y


        width: dial_x_axis.width/2
        height: width
        radius: width/2
        border.width: width/10

        color: Qt.darker(root.bg_color)
        border.color: Qt.darker(color)

        Text{
            id: text_go_to_origin_btn
            text: "0"
            color: root.text_color
            font.pointSize: parent.width/2
            anchors.centerIn: parent
        }

        MouseArea{
            id: mouse_area_go_to_origin_btn

            property bool pressed: false

            anchors.fill: parent

            onPressed:{
                go_to_origin_btn.color = Qt.darker(go_to_origin_btn.color)
                go_to_origin_btn.border.color = Qt.darker(go_to_origin_btn.border.color)
                text_go_to_origin_btn.color = Qt.darker(text_go_to_origin_btn.color)
                pressed = true
            }

            onExited:{
                if(pressed){
                    go_to_origin_btn.color = Qt.darker(root.bg_color)
                    go_to_origin_btn.border.color = Qt.darker(go_to_origin_btn.color)
                    text_go_to_origin_btn.color = root.text_color
                    pressed = false
                }
            }

            onReleased:{
                if(pressed){
                    Model.changeXLimits(-5, 5)
                    Model.changeYLimits(-5, 5)
                    go_to_origin_btn.color = Qt.darker(root.bg_color)
                    go_to_origin_btn.border.color = Qt.darker(go_to_origin_btn.color)
                    text_go_to_origin_btn.color = root.text_color
                    pressed = false
                }
            }
        }
    }


    //see whole curve button
    Rectangle{
        id: see_whole_curve_btn

        x: go_to_origin_btn.x
        y: go_to_origin_btn.y + go_to_origin_btn.height*1.1

        width: dial_x_axis.width/2
        height: width
        border.width: width/10
        radius: width/20

        color: Qt.darker(Qt.darker(root.bg_color))
        border.color: Qt.darker(color)

        Rectangle{
            id: symbol_see_whole_curve

            x: (parent.width - width)/2
            y: (parent.height - height)/2

            width: parent.width/2
            height: width
            border.width: width/7

            color: Qt.rgba(0,0,0,0)
            border.color: Qt.darker(root.text_color)
        }

        MouseArea{
            id: mouse_area_see_whole_curve_btn

            property bool active: false
            anchors.fill: parent

            onClicked:{
                Model.setSeeWholeCurve(!Model.getSeeWholeCurve())
                active = Model.getSeeWholeCurve()
                if(active){
                    see_whole_curve_btn.color = Qt.darker(root.bg_color)
                    see_whole_curve_btn.border.color = Qt.darker(see_whole_curve_btn.color)
                    symbol_see_whole_curve.border.color = root.text_color
                }else{
                    see_whole_curve_btn.color = Qt.darker(Qt.darker(root.bg_color))
                    see_whole_curve_btn.border.color = Qt.darker(Qt.darker(see_whole_curve_btn.color))
                    symbol_see_whole_curve.border.color = Qt.darker(root.text_color)
                }
            }
        }
    }


    //Clear line button
    Rectangle{
        id: clear_line_btn

        x: see_whole_curve_btn.x + see_whole_curve_btn.width*1.1
        y: see_whole_curve_btn.y

        width: dial_x_axis.width/2
        height: width
        border.width: width/10
        radius: width/2

        color: Qt.darker(root.bg_color)
        border.color: Qt.darker(color)

        Text{
            id: text_clear_line_btn

            text: "Clear"

            color: root.text_color
            font.pointSize: parent.width/5
            anchors.centerIn: parent
        }

        MouseArea{
            id: mouse_area_clear_line_btn

            property bool pressed: false

            anchors.fill: parent

            onPressed:{
                clear_line_btn.color = Qt.darker(clear_line_btn.color)
                clear_line_btn.border.color = Qt.darker(clear_line_btn.border.color)
                text_clear_line_btn.color = Qt.darker(text_clear_line_btn.color)
                pressed = true
            }
            onExited:{
                if(pressed){
                    clear_line_btn.color = Qt.darker(root.bg_color)
                    clear_line_btn.border.color = Qt.darker(clear_line_btn.color)
                    text_clear_line_btn.color = root.text_color
                    pressed = false
                }
            }
            onReleased:{
                if(pressed){
                    Model.clearLine()
                    clear_line_btn.color = Qt.darker(root.bg_color)
                    clear_line_btn.border.color = Qt.darker(clear_line_btn.color)
                    text_clear_line_btn.color = root.text_color
                    pressed = false
                }
            }
        }
    }

    //Eliminate line button
    Rectangle{
        id: eliminate_btn

        x: clear_line_btn.x + clear_line_btn.width*1.1
        y: clear_line_btn.y

        width: dial_x_axis.width/2
        height: width
        border.width: width/10
        radius: width/2

        color: Qt.darker(root.bg_color)
        border.color: Qt.darker(color)

        Text{
            id: text_eliminate_btn

            text: "Remove"

            color: root.text_color
            font.pointSize: parent.width/6
            anchors.centerIn: parent
        }

        MouseArea{
            id: mouse_area_eliminate_btn

            property bool pressed: false

            anchors.fill: parent

            onPressed:{
                eliminate_btn.color = Qt.darker(Qt.darker(root.bg_color))
                eliminate_btn.border.color = Qt.darker(Qt.darker(eliminate_btn.color))
                text_eliminate_btn.color = Qt.darker(root.text_color)
                pressed = true
            }
            onExited:{
                if(pressed){
                    eliminate_btn.color = Qt.darker(root.bg_color)
                    eliminate_btn.border.color = Qt.darker(eliminate_btn.color)
                    text_eliminate_btn.color = root.text_color
                    pressed = false
                }
            }
            onReleased:{
                if(pressed){
                    Model.removeLine()
                    eliminate_btn.color = Qt.darker(root.bg_color)
                    eliminate_btn.border.color = Qt.darker(eliminate_btn.color)
                    text_eliminate_btn.color = root.text_color
                    pressed = false
                }
            }
        }
    }


    //plot follow button
    Rectangle{
        id: plot_following_btn

        x: go_to_origin_btn.x + go_to_origin_btn.width*1.1
        y: dial_y_axis.y

        width: dial_x_axis.width/2
        height: width
        radius: width/20

        border.width: width/10

        color: Qt.darker(Qt.darker(root.bg_color))
        border.color: Qt.darker(Qt.darker(color))

        Shape{
            id: plot_following_symbol

            x: parent.width*3/10 - (plot_following_btn.width*3*Math.sqrt(3)/10)/2

            width:parent.width
            height: parent.height

            ShapePath{
                id: shape_path_plot_following_symbol

                strokeWidth: plot_following_btn.width/10
                strokeColor: Qt.darker(root.text_color)
                fillColor: Qt.rgba(0,0,0,0)

                startX: plot_following_btn.width/5; startY: plot_following_btn.height/5
                PathLine{x: plot_following_btn.width/5 + plot_following_btn.width*3*Math.sqrt(3)/10; y: plot_following_btn.height/2}
                PathLine{x: plot_following_btn.width/5; y: plot_following_btn.height*4/5}
            }
        }

        MouseArea{
            id: mouse_area_plot_following_btn

            property bool active: false

            anchors.fill: parent

            onClicked:{
                Model.setPlotFollowing(!Model.getPlotFollowing())
                active = Model.getPlotFollowing()
                if(active){
                    plot_following_btn.color = Qt.darker(root.bg_color)
                    plot_following_btn.border.color = Qt.darker(plot_following_btn.color)
                    shape_path_plot_following_symbol.strokeColor = root.text_color
                }else{
                    plot_following_btn.color = Qt.darker(Qt.darker(root.bg_color))
                    plot_following_btn.border.color = Qt.darker(Qt.darker(plot_following_btn.color))
                    shape_path_plot_following_symbol.strokeColor = Qt.darker(root.text_color)
                }
            }
        }
    }

    //Show point button
    Rectangle{
        id: show_points_btn

        x: plot_following_btn.x + plot_following_btn.width*1.1
        y: dial_y_axis.y

        width: dial_x_axis.width/2
        height: width
        border.width: width/10
        radius: width/20

        color: Qt.darker(Qt.darker(root.bg_color))
        border.color: Qt.darker(Qt.darker(color))

        Rectangle{
            id: show_points_symbol

            anchors.centerIn: parent
            width: parent.width/2
            height: width
            radius: width/2
            color: Qt.darker(root.text_color)
        }

        MouseArea{
            id: mouse_area_show_points_btn

            anchors.fill: parent
            onClicked:{
                Model.setShowPoints(!Model.getShowPoints())
                if(Model.getShowPoints()){
                    show_points_btn.color = Qt.darker(root.bg_color)
                    show_points_btn.border.color = Qt.darker(show_points_btn.color)
                    show_points_symbol.color = root.text_color
                }else{
                    show_points_btn.color = Qt.darker(show_points_btn.color)
                    show_points_btn.border.color = Qt.darker(show_points_btn.border.color)
                    show_points_symbol.color = Qt.darker(root.text_color)
                }
            }
        }
    }


    //X limit controls
    Rectangle{
        id: label_x_limit_bg

        x: show_points_btn.x + show_points_btn.width*4
        y: root.height/2 - height*1.5

        width: (root.width - show_points_btn.x)/6
        height: 1/4*width

        color: root.bg_color
        border.color: Qt.darker(color)

        Text{
            id:text_min_x_limit

            anchors.centerIn: parent
            text: "X Axis: "
            font.pointSize: label_x_limit_bg.height/2
            color: root.text_color
        }

        Rectangle{
            id: label_min_limit_bg

            y: -height*1.5
            anchors.horizontalCenter: min_x_limit.horizontalCenter

            width: (root.width - show_points_btn.x)/6
            height: 1/4*width

            color: root.bg_color
            border.color: Qt.darker(color)

            Text{
                id: text_min_limit

                anchors.centerIn: parent
                text: "Left Limit"
                font.pointSize: label_min_limit_bg.height/2
                color: root.text_color
            }
        }

        Rectangle{
            id: label_max_limit_bg

            anchors.horizontalCenter: max_x_limit.horizontalCenter
            y: -height*1.5

            width: (root.width - show_points_btn.x)/6
            height: 1/4*width

            color: root.bg_color
            border.color: Qt.darker(color)

            Text{
                id: text_max_limit

                anchors.centerIn: parent
                text: "Right Limit"
                font.pointSize: label_max_limit_bg.height/2
                color: root.text_color
            }
        }

        CustomTextEdit{
            id: min_x_limit

            x: label_x_limit_bg.width + width/4

            width: label_x_limit_bg.width
            height: label_x_limit_bg.height

            mode: "x_min"
            text_color: root.text_color

            anchors_mouse_area: root.anchors_mouse_area
        }
        CustomTextEdit{
            id: max_x_limit

            x: min_x_limit.x + min_x_limit.width*1.5

            width: label_x_limit_bg.width
            height: label_x_limit_bg.height

            mode: "x_max"
            text_color: root.text_color

            anchors_mouse_area: root.anchors_mouse_area
        }
    }

    //Y limit controls
    Rectangle{
        id: label_y_limit_bg

        y: root.height/2 + height*1.5
        x: show_points_btn.x + show_points_btn.width*4

        width: (root.width - show_points_btn.x)/6
        height: 1/4*width

        color: root.bg_color
        border.color: Qt.darker(color)

        Text{
            id: text_min_y_limit

            anchors.centerIn: parent
            text: "Y Axis:"
            font.pointSize: label_y_limit_bg.height/2
            color: root.text_color
        }

        CustomTextEdit{
            id: min_y_limit

            x: label_y_limit_bg.width + width/4

            width: label_y_limit_bg.width
            height: label_y_limit_bg.height

            mode: "y_min"
            text_color: root.text_color

            anchors_mouse_area: root.anchors_mouse_area
        }
        CustomTextEdit{
            id: max_y_limit

            x: min_y_limit.x + min_y_limit.width*1.5

            width: label_y_limit_bg.width
            height: label_y_limit_bg.height

            mode: "y_max"
            text_color: root.text_color

            anchors_mouse_area: root.anchors_mouse_area
        }
    }

    Connections{
        target: Model

        function onUpdateGraphControls(){
            dial_x_axis.value = Model.getAxisZoom()[0]
            spin_box_x_axis.value = dial_x_axis.value

            dial_y_axis.value = Model.getAxisZoom()[1]
            spin_box_y_axis.value = dial_y_axis.value
        }

        function onSelectedLineChanged(){
            if(Model.getSelectedLine() === "All" || Model.getSelectedLine() === ""){
                if(mouse_area_plot_following_btn.active){
                    plot_following_btn.color = Qt.darker(Qt.darker(root.bg_color))
                    plot_following_btn.border.color = Qt.darker(Qt.darker(plot_following_btn.color))
                    shape_path_plot_following_symbol.strokeColor = Qt.darker(root.text_color)
                    mouse_area_plot_following_btn.active = Model.getPlotFollowing()
                }
            }
            if(Model.getSelectedLine() === ""){
                if(mouse_area_see_whole_curve_btn.active){
                    mouse_area_see_whole_curve_btn.active = false
                    see_whole_curve_btn.color = Qt.darker(Qt.darker(root.bg_color))
                    see_whole_curve_btn.border.color = Qt.darker(Qt.darker(see_whole_curve_btn.color))
                    symbol_see_whole_curve.border.color = Qt.darker(root.text_color)
                }
            }
        }

        function onPlotFollowingChanged(){
            mouse_area_plot_following_btn.active = Model.getPlotFollowing()
            if(mouse_area_plot_following_btn.active){
                plot_following_btn.color = Qt.darker(root.bg_color)
                plot_following_btn.border.color = Qt.darker(plot_following_btn.color)
                shape_path_plot_following_symbol.strokeColor = root.text_color
            }else{
                plot_following_btn.color = Qt.darker(Qt.darker(root.bg_color))
                plot_following_btn.border.color = Qt.darker(Qt.darker(plot_following_btn.color))
                shape_path_plot_following_symbol.strokeColor = Qt.darker(root.text_color)
            }
        }

        function onSeeWholeCurveChanged(){
            mouse_area_see_whole_curve_btn.active = Model.getSeeWholeCurve()
            if(mouse_area_see_whole_curve_btn.active){
                see_whole_curve_btn.color = Qt.darker(root.bg_color)
                see_whole_curve_btn.border.color = Qt.darker(see_whole_curve_btn.color)
                symbol_see_whole_curve.border.color = root.text_color
            }else{
                see_whole_curve_btn.color = Qt.darker(Qt.darker(root.bg_color))
                see_whole_curve_btn.border.color = Qt.darker(Qt.darker(see_whole_curve_btn.color))
                symbol_see_whole_curve.border.color = Qt.darker(root.text_color)
            }
        }
    }
}
