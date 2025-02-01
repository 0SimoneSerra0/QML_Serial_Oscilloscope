import QtQuick
import QtGraphs
import MyModel
import QtQuick.Controls
import QtQuick.Layouts
import "scripts.js" as Scripts

Item {
    id:root
    property color color: "#2d2d2d"

    Rectangle{
        id: graph_bg

        width: root.width
        height: root.height

        color: Qt.darker(root.color)

        //shortcut for zoom in and out
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





        //lights in the bottom left of the graph part
        Rectangle{
            id: state_light_close

            y: graph_bg.height - height

            width: 1/100*graph_bg.width
            height: width
            radius: 50

            color: "red"

            Rectangle{
                id: state_light_open

                x: state_light_close.width*1.5

                width: state_light_close.width
                height: width
                radius: state_light_close.radius

                color: Qt.darker("green")
            }
        }

        RowLayout{
            id: layout_line_selector

            x: state_light_open.x + state_light_open.width*2
            y: graph_bg.height - height*0.9

            width: graph_bg.width - x
            height: graph_bg.height - graph.y - graph.height
        }
    }


    GraphsView{
        id:graph

        anchors.fill: parent
        anchors.margins: width/50

        theme: GraphsTheme {
            readonly property color c1: "#ffffff"
            readonly property color c2: "#000000"
            readonly property color c3: Qt.lighter(c2, 1.5)

            colorScheme: GraphsTheme.ColorScheme.Dark

            seriesColors: ["#2CDE85", "#DBEB00"]

            property double grid_width: graph.width/760
            grid.mainWidth: grid_width
            grid.subWidth: grid_width/2

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

            min: Model.getZoomedXAxisLimits()[0]
            max: Model.getZoomedXAxisLimits()[1]
            tickInterval: 1
            subTickCount: 1
            labelDecimals: 3
        }

        axisY: ValueAxis {
            id:y_axis

            min: Model.getZoomedYAxisLimits()[0]
            max: Model.getZoomedYAxisLimits()[1]
            tickInterval: 1
            subTickCount: 1
            labelDecimals: 3
        }
    }

    MouseArea{
        id: mouse_area_graph

        property double init_x
        property double init_y

        anchors.fill: graph

        //to let the MouseArea of the points of the graph series recive the mouse input
        propagateComposedEvents: true

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

        //handle the movment of the mouse while pressed on the graph
        Timer{
            id: update_drag_timer

            property real deltaX
            property real deltaY

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


    //handle all the intrested signal from the Model
    Connections{
        target: Model

        function onPortStateChanged(state){
            state_light_close.color = state ? Qt.darker("red") : "red"
            state_light_open.color = state ? "green" : Qt.darker("green")
        }

        function onUpdateLine(name){
            if(Scripts.getLineSeries(name) === null){
                Scripts.createLineSeries(graph, name, Model.getLineColor(name))
                graph.addSeries(Scripts.getLineSeries(name))
            }
            Scripts.appendToLineSeries(name, Model.getLine(name)[Model.getLine(name).length - 1].x, Model.getLine(name)[Model.getLine(name).length - 1].y)
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
            var s = Model.getSelectedLine()
            var points
            if(s === "")
                return
            if(s === "All"){
                for(let [name, series] of Scripts.getAllLineSeries()){
                    series.clear()
                    points = Model.getLine(name)
                    for(var i = 0; i < points.length; i+=1){
                        series.append(points[i].x(), points[i].y())
                    }
                }
            }else{
                if(Scripts.getLineSeries(s) === null)
                    return
                Scripts.getLineSeries(s).clear()
                points = Model.getLine(s)
                for(i = 0; i < points.length; i+=1){
                    Scripts.getLineSeries(s).append(points[i].x(), points[i].y())
                }
            }
        }

        function onLineAdded(line_name){
            Scripts.createLineSelectorElement(layout_line_selector, line_name, Qt.lighter(root.color), "#afafaf", Model.getLineColor(line_name))
        }

        function onLineRemoved(line_name){
            Scripts.eliminateLineSelector(line_name)
            if(line_name === "All"){
                for(var [name, l] of Scripts.getAllLineSeries())
                    graph.removeSeries(name)
            }else if(Scripts.getLineSeries(line_name) !== undefined){
                graph.removeSeries(Scripts.getLineSeries(line_name))
            }
            Scripts.eliminateLineSeries(line_name)
            return
        }
    }
}

