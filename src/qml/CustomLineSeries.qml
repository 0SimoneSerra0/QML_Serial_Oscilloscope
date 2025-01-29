import QtQuick
import QtGraphs
import MyModel
import "scripts.js" as Scripts

pragma ComponentBehavior: Bound

//Line series used in the graph that let the user select its point and use the
//point coordinates UI
LineSeries {
    id: root
    property var graph

    //Point showed in the line when the Model::show_points is true
    pointDelegate: Rectangle{
        id: marker

        property int index
        Component.onCompleted: {
            index = root.count
        }
        property bool clicked: false

        width: root.width * 4
        height: width
        border.width: 4
        radius: width/2

        color: "#ffffff"
        border.color: "#000000"
        opacity: Model.getShowPoints() ? 1 : 0

        MouseArea{
            id: mouse_area_marker

            anchors.fill: parent

            //function used in Scripts.destroyLabel()
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
                        Scripts.createLabelPointCoordinates(mouse_area_marker, root.at(marker.index - 1).x, root.at(marker.index - 1).y)
                    }else{
                        marker.color = "#ffffff"
                        marker.border.color = "#000000"
                        Scripts.destroyLabel()
                    }
                }
            }
        }

        Connections{
            target: Model
            function onShowPointsChanged(){
                marker.opacity = Model.getShowPoints() ? 1 : 0
            }
        }
    }
}
