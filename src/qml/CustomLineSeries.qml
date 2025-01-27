import QtQuick
import QtGraphs
import MyModel
import "scripts.js" as Scripts

pragma ComponentBehavior: Bound

LineSeries {
    id: root
    property var graph

    function setLabelToNull(){
        Scripts.resetLabel()
    }

    pointDelegate: Rectangle{
        id: marker
        property bool clicked: false
        width: 16
        height: 16
        color: "#ffffff"
        opacity: Model.getShowPoints() ? 1 : 0
        radius: width * 0.5
        border.width: 4
        border.color: "#000000"
        Connections{
            target: Model
            function onShowPointsChanged(){
                marker.opacity = Model.getShowPoints() ? 1 : 0
            }
        }
        MouseArea{
            id: mouse_area_marker
            anchors.fill: parent
            function deselectMarker(){
                marker.color = "#ffffff"
                marker.border.color = "#000000"
            }
            onClicked:{
                if(marker.opacity !== 0){
                    marker.clicked = !marker.clicked
                    if(marker.clicked){
                        marker.color = Qt.darker(marker.color)
                        marker.border.color = Qt.darker(marker.border.color)
                        Scripts.destroyLabel()
                        Scripts.createLabelPointCoordinates(mouse_area_marker, root.at(root.graph.children[1].children.indexOf(marker)-1).x, root.at(root.graph.children[1].children.indexOf(marker)-1).y)
                    }else{
                        marker.color = "#ffffff"
                        marker.border.color = "#000000"
                        Scripts.destroyLabel()
                    }
                }
            }
        }
    }
}
