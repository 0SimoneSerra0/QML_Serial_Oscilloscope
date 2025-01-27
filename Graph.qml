import QtQuick
import QtGraphs
import MyModel
import QtQuick.Controls
import "scripts.js" as Scripts

Item {
    id:root
    property color color: "#2d2d2d"

    Rectangle{
        id: graph_bg
        color: Qt.darker("#2d2d2d")
        width: root.width
        height: root.height



        Shortcut{
            id: shrct_zoom_in
            sequences: ["Ctrl++"]
            onActivated: zoom_in.trigger()
        }
        Shortcut{
            id: shrct_zoom_out
            sequences: ["Ctrl+-"]
            onActivated: zoom_out.trigger()
        }

        Action {
            id: zoom_in
            onTriggered:{
                Model.zoomIn()
            }
        }
        Action{
            id: zoom_out
            onTriggered:{
                Model.zoomOut()
            }
        }


        MouseArea{
            id: mouse_area_graph
            anchors.fill: parent

            property double init_x
            property double init_y
            onPressed:{
                init_x = mouseX
                init_y = mouseY
                update_drag_timer.start()
            }
            onReleased:{
                update_drag_timer.stop()
            }
            onExited:{
                update_drag_timer.stop()
            }
            onWheel:{
                Model.changeXLimits(Model.getXAxisLimits()[0] + wheel.angleDelta.x*0.5, Model.getXAxisLimits()[1] - wheel.angleDelta.x*0.5)
                Model.changeYLimits(Model.getYAxisLimits()[0] + wheel.angleDelta.y*0.5, Model.getYAxisLimits()[1] - wheel.angleDelta.y*0.5)
            }

            Timer{
                property real deltaX
                property real deltaY
                id: update_drag_timer
                repeat: true
                interval: 5
                onTriggered:{
                    deltaX = Math.abs(Model.getZoomedXAxisLimits()[1] - Model.getZoomedXAxisLimits()[0])*(mouse_area_graph.init_x - mouse_area_graph.mouseX)/(graph.width*0.9)
                    deltaY = Math.abs(Model.getZoomedYAxisLimits()[1] - Model.getZoomedYAxisLimits()[0])*(mouse_area_graph.init_y - mouse_area_graph.mouseY)/(graph.height*0.84)

                    Model.changeXLimits(Model.getXAxisLimits()[0] + deltaX, Model.getXAxisLimits()[1] + deltaX);
                    Model.changeYLimits(Model.getYAxisLimits()[0] - deltaY, Model.getYAxisLimits()[1] - deltaY);

                    mouse_area_graph.init_x = mouse_area_graph.mouseX
                    mouse_area_graph.init_y = mouse_area_graph.mouseY
                }
            }
        }

        Rectangle{
            id: state_light_close
            y: graph_bg.height - height
            width: 1/100*graph_bg.width
            height: width
            radius: 50
            color: "red"

            Rectangle{
                id: state_light_open
                width: state_light_close.width
                height: width
                radius: state_light_close.radius
                color: Qt.darker("green")
                x: state_light_close.width*1.5
            }

            Connections{
                target: Model
                property int i: 0
                property var points
                function onUpdateStateLights(state){
                    state_light_close.color = state ? Qt.darker("red") : "red"
                    state_light_open.color = state ? "green" : Qt.darker("green")
                }
                function onUpdateLine(){
                    line_series.append(Model.getLine()[Model.getLine().length - 1].x, Model.getLine()[Model.getLine().length - 1].y)
                }
                function onUpdateAxis(){
                    x_axis.min = Model.getZoomedXAxisLimits()[0]
                    x_axis.max = Model.getZoomedXAxisLimits()[1]
                    x_axis.tickInterval = (x_axis.max - x_axis.min)/10

                    y_axis.min = Model.getZoomedYAxisLimits()[0]
                    y_axis.max = Model.getZoomedYAxisLimits()[1]
                    y_axis.tickInterval = (y_axis.max - y_axis.min)/10
                }
                function onRefreshLine(){
                    line_series.clear()
                    line_series.setLabelToNull()
                    points = Model.getLine()
                    for(i = 0; i < points.length; i+=1){
                        line_series.append(points[i].x(), points[i].y())
                    }
                }
            }
        }

        GraphsView {
            id:graph
            anchors.fill: parent
            anchors.margins: 16

            theme: GraphsTheme {
                readonly property color c1: "#ffffff"
                readonly property color c2: "#000000"
                readonly property color c3: Qt.lighter(c2, 1.5)

                colorScheme: GraphsTheme.ColorScheme.Dark

                seriesColors: ["#2CDE85", "#DBEB00"]

                grid.mainColor: c3
                grid.subColor: c2
                axisX.mainColor: c3
                axisY.mainColor: c3
                axisX.subColor: c2
                axisY.subColor: c2
                axisX.labelTextColor: c1
                axisY.labelTextColor: c1
            }

            axisX: ValueAxis {
                id:x_axis
                max: 10
                tickInterval: 1
                subTickCount: 1
                labelDecimals: 1
            }

            axisY: ValueAxis {
                id:y_axis
                max: 10
                tickInterval: 1
                subTickCount: 1
                labelDecimals: 1
            }

            CustomLineSeries {
                id: line_series
                graph: graph
                width: graph.width/250
            }
        }
    }
}
