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

    function setLabelToNull(){
        Scripts.resetLabel()
    }

    //Point showed in the line when the Model::show_points is true
    pointDelegate: Rectangle{
        id: marker

        property bool clicked: false

        width: 16
        height: 16
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


                        //this function wnats the parent of the
                        //LabelPointCoordinates and an x and y value,
                        //it gets them by accessing the graph PointRenderer child
                        //and seeing at wich index is the point, once it know that
                        //it access the point of the series at the index just found
                        Scripts.createLabelPointCoordinates(mouse_area_marker, root.at(root.graph.children[1].children.indexOf(marker)-1).x, root.at(root.graph.children[1].children.indexOf(marker)-1).y)
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
