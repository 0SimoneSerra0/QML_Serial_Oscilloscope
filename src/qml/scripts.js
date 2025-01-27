var component;
var label = null;
var _parent;
var _y;
var _x


function createLabelPointCoordinates(parent, x, y) {
    component = Qt.createComponent("LabelPointCoordinates.qml");
    _y = y
    _x = x
    _parent = parent
    if (component.status === Component.Ready)
        finishCreation();
    else
        component.statusChanged.connect(finishCreation);
}

function finishCreation() {
    if (component.status === Component.Ready) {
        label = component.createObject(_parent, {"anchors.top": _parent.bottom, txt_x: _x, txt_y: _y});
        if (label === null) {
            console.log("Error creating object");
        }
    } else if (component.status === Component.Error) {
        console.log("Error loading component:", component.errorString());
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
