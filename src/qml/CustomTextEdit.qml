import QtQuick
import QtQuick.Controls
import MyModel


//custom text edit meant to be used only for the axis limts
Item {
    id: root

    property color text_color

    //this property is needed for understanding which limit the text edit should
    //handle
    property string mode

    function getAxisLimit(){
        switch(mode){
        case "x_min":
            return Model.getXAxisLimits()[0]
        case "x_max":
            return Model.getXAxisLimits()[1]
        case "y_min":
            return Model.getYAxisLimits()[0]
        case "y_max":
            return Model.getYAxisLimits()[1]
        }
    }

    function setAxisLimit(value){
        switch(mode){
        case "x_min":
            return Model.changeXLimits(value, Model.getXAxisLimits()[1])
        case "x_max":
            return Model.changeXLimits(Model.getXAxisLimits()[0] ,value)
        case "y_min":
            return Model.changeYLimits(value, Model.getYAxisLimits()[1])
        case "y_max":
            return Model.changeYLimits(Model.getYAxisLimits()[0], value)
        }
    }

    TextField{
        id: limit
        text: String(parseFloat(root.getAxisLimit()).toFixed(3))
        width: root.width
        height: root.height
        color: root.text_color

        property int i: 0
        property bool point: false
        property int init_char: 1
        property bool val_just_updated: false


        onTextChanged:{
            if(!Model.getPlotFollowing()){
                point = false
                init_char = 1

                if(text.length > 0){
                    //while the first character is invalid (so different
                    //from a digit, point or minus symbol) it gets removed
                    while(!(text.charCodeAt(0) >= 48 && text.charCodeAt(0)<=57 || (text.charCodeAt(0) === 46 && !point) || text.charCodeAt(0) === 45)){
                        text = text.length > 1 ? text.substr(1) : ""
                    }
                    //if the first char is a point, it gets automatically added
                    //a 0 before that
                    if(text.charCodeAt(0) === 46){
                        text = "0." + text.substr(text.indexOf(".") + 1)
                        point = true
                        init_char = text.indexOf(".") + 1
                    }
                    //if there is a minus as the first character the user cannot input
                    //a point as the second one
                    else if(text.charCodeAt(0) === 45 && text.charCodeAt(1) === 46){
                        text = "-" + text.substr(text.indexOf(".") + 1)
                        init_char = 1
                    }
                }

                for(i = init_char; i < text.length; i+=1){
                    //it checks if the caracter at index i is valid (is a
                    //digit or a point if there isn't already anoter in the string)
                    if(!(text.charCodeAt(i) >= 48 && text.charCodeAt(i)<=57 || (text.charCodeAt(i) === 46 && !point))){
                        text = text.substr(0, i) + text.substr(i+1)
                        i-=1
                    }else if(text.charCodeAt(i) === 46){
                        point = true
                    }
                }
            }else{
                text = String(parseFloat(root.getAxisLimit()).toFixed(3))
            }
        }

        onAccepted:{
            if(text === "" || text === "-")
                text = "0"
            else if(text.charAt(text.length - 1) === '.')
                text = text.substr(0, text.length-1)

            switch(root.mode){
            case "x_min":
                //it checks if the text is less than the max x limit
                if(!(parseFloat(text) <= Model.getXAxisLimits()[1] - Model.getMinDistanceBetweenAxisLimits())){
                    text = String(parseFloat(root.getAxisLimit()).toFixed(3))
                    return
                }
                break
            case "x_max":
                //it checks if the text is greatr than the min x limit
                if(parseFloat(text) <= Model.getXAxisLimits()[0] + Model.getMinDistanceBetweenAxisLimits()){
                    text = String(parseFloat(root.getAxisLimit()).toFixed(3))
                    return
                }
                break
            case "y_min":
                //it checks if the text is less than the max y limit
                if(!(parseFloat(text) <= Model.getYAxisLimits()[1] - Model.getMinDistanceBetweenAxisLimits())){
                    text = String(parseFloat(root.getAxisLimit()).toFixed(3))
                    return
                }
                break
            case "y_max":
                //it checks if the text is greatr than the min y limit
                if(parseFloat(text) <= Model.getYAxisLimits()[0] + Model.getMinDistanceBetweenAxisLimits()){
                    text = String(parseFloat(root.getAxisLimit()).toFixed(3))
                    return
                }
                break
            }
            val_just_updated = true
            root.setAxisLimit(parseFloat(text))
        }
        Connections{
            target: Model
            function onUpdateAxis(){
                //if val_just_updated is true that means the updateAxis signal was
                //called by the text edit himself, so it already has the right value
                if(!limit.val_just_updated){
                    limit.text = String(parseFloat(root.getAxisLimit()).toFixed(3))
                }else{
                    limit.val_just_updated = false
                }
            }
        }
    }
}
