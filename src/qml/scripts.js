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

        if (line_series === null) {
            console.log("Error creating object");
        }else{
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

function getAllLineSeries(){
    return all_line_series
}





var component_line_selector
var line_selector
var parent_ls
var name_ls
var bg_color_ls
var text_color_ls
var line_color_ls
var all_line_selectors = []

function createLineSelectorElement(parent, line_name, bg_color, text_color, line_color, creatingFirst = false){

    if(!creatingFirst && all_line_selectors.length == 0)
        createLineSelectorElement(parent, "All", bg_color, text_color, Qt.rgba(0,0,0,0), true)

    component_line_selector = Qt.createComponent("LineSelectorElement.qml")
    parent_ls = parent
    name_ls = line_name
    bg_color_ls = bg_color
    text_color_ls = text_color
    line_color_ls = line_color

    if(component_line_selector.status === Component.Ready){
        finshLineSelectorCreation()
    }else{
        component_line_selector.statusChanged.connect(finshLineSelectorCreation)
    }
}


function finshLineSelectorCreation(){
    if (component_line_selector.status === Component.Ready) {

        line_selector = component_line_selector.createObject(parent_ls, {height: parent_ls.height, line_name: name_ls, bg_color: bg_color_ls, text_color: text_color_ls, line_color: line_color_ls})

        if (line_selector === null) {
            console.log("Error creating object");
        }else{
            all_line_selectors.push(line_selector)
        }
    } else if (component_line_selector.status === Component.Error) {
        console.log("Error loading component:", component_line_selector.errorString());
    }
}
