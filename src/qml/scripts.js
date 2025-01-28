//This file contains the required function to dnamically create a
//LabelPointCoordinates


var component_label
var label = null
var parent_label = null
var _y = 0
var _x = 0


function createLabelPointCoordinates(parent, x, y) {
    component_label = Qt.createComponent("LabelPointCoordinates.qml")
    _y = y
    _x = x
    parent_label = parent
    if (component_label.status === Component.Ready)
        finishLabelCreation()
    else
        component_label.statusChanged.connect(finishLabelCreation)
}

function finishLabelCreation() {
    if (component_label.status === Component.Ready) {
        label = component_label.createObject(parent_label, {"anchors.top": parent_label.bottom, txt_x: _x, txt_y: _y})
        if (label === null) {
            console.log("Error creating object");
        }
    } else if (component_label.status === Component.Error) {
        console.log("Error loading component:", component_label.errorString())
    }
}

function resetLabel(){
    label = null
}

function destroyLabel(){
    if(label !== null){
        label.parent.deselectMarker()
        label.destroy()
        label = null
    }
}



var component_line_series
var line_series
var parent_line_series
var _name
var _color
var all_line_series = new Map()

function createLineSeries(parent, name, color) {
    component_line_series = Qt.createComponent("CustomLineSeries.qml");
    parent_line_series = parent
    _name = name
    _color = color

    if (component_line_series.status === Component.Ready){
        finishLineSeriesCreation()
    }
    else{
        component_line_series.statusChanged.connect(finishLineSeriesCreation);
    }
}

function finishLineSeriesCreation() {
    if (component_line_series.status === Component.Ready) {
        line_series = component_line_series.createObject(parent_line_series, {name: _name, graph: parent_line_series, color: _color, width: 4});
        console.log(line_series)

        if (line_series === null) {
            console.log("Error creating object");
        }else{
            console.log(line_series)
            all_line_series.set(_name, line_series)
        }
    } else if (component_line_series.status === Component.Error) {
        console.log("Error loading component:", component_line_series.errorString());
    }
}

function getLineSeries(name){
    let _l = all_line_series.get(name)
    if(_l === undefined){
        return null
    }else{
        return _l
    }
}

function appendToLineSeries(name, x, y){
    all_line_series.get(name).append(x, y)
}
