#include "header/model.h"

Model::Model(QObject *parent)
    : QObject{parent}
{
    serial_port = new QSerialPort(this);

    QObject::connect(serial_port, SIGNAL(readyRead()), this, SLOT(getNewValueFromSerialPort()));
}



Model::~Model(){
    if(serial_port->isOpen())
        serial_port->close();

    for(auto& l : lines){
        delete l.second;
        lines.erase(lines.find(l.first));
    }
}



/*
 *getAllAvailablePortName():
 *  The qml part use this method to get the model for the serial port spinbox
*/
std::vector<QString> Model::getAllAvailablePortName(){
    std::vector<QString> p_names;

    for(QSerialPortInfo p : QSerialPortInfo::availablePorts()){
        p_names.push_back(p.portName());
    }

    return p_names;
}



/*
 *getCommonBaudRates()
 *  The qml part use this method to get the model for the baud rate spinbox
*/
std::vector<uint32_t> Model::getCommonBaudRates()
{
    return {110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200, 128000, 256000};
}



/*
 *getPossibleParity()
 *  The qml part use this method to get the model for the parity spinbox
*/
std::vector<QString> Model::getPossibleParity()
{
    return {"Parity None", "Parity Odd", "Parity Even", "Parity Mark", "Parity Space"};
}


/*
 *getPossibleStopBits()
 *  The qml part use this method to get the model for the stop bits spinbox
*/
std::vector<QString> Model::getPossibleStopBits()
{
    return {"One Stop", "Two Stop", "One and half Stop"};
}



/*
 *getPossibleFlowControls()
 *  The qml part use this method to get the model for the flow control spinbox
*/
std::vector<QString> Model::getPossibleFlowControls()
{
    return {"No flow control", "Hardware flow control", "Software flow control"};
}






/*
 *changePort(uint16_t)
 *  Open a serial port given the index in the vector returned by the function
 *  "getAllAvailablePortName()"
*/
int Model::changePort(uint16_t port_index){
    if(serial_port->isOpen())
        serial_port->close();

    if(port_index >= QSerialPortInfo::availablePorts().size()){
        QString mes = "Error: Invalid index given to function 'changePort(uint16_t)'";
        qDebug() << mes;
        emit emitAddText(mes);
        return -1;
    }

    QSerialPortInfo p = QSerialPortInfo::availablePorts()[port_index];

    serial_port->setPort(p);
    emit portChanged(false);
    emit updateStateLights(false);
    return 0;
}



bool Model::changeBaudRate(uint8_t index)
{
    if(serial_port->setBaudRate(getCommonBaudRates()[index]))
        return true;
    else{
        QString mes = "Error while changing port '" + serial_port->portName() + "' baud rate\nError description: " + serial_port->errorString();
        qDebug() << mes;
        emit emitAddText(mes);
        return false;
    }
}



bool Model::changeDataBits(uint8_t new_value)
{
    if(serial_port->setDataBits(QSerialPort::DataBits(new_value))){
        return true;
    }else{
        QString mes = "Error while changing port '" + serial_port->portName() + "' data bits\nError description: " + serial_port->errorString();
        qDebug() << mes;
        emit emitAddText(mes);
        return false;
    }
}



bool Model::changeParity(uint8_t index)
{
    if(serial_port->setParity( index == 0 ? QSerialPort::Parity(index) : QSerialPort::Parity(index + 1) ) ){
        return true;
    }else{
        QString mes = "Error while changing port '" + serial_port->portName() + "' parity\nError description: " + serial_port->errorString();
        qDebug() << mes;
        emit emitAddText(mes);
        return false;
    }
}



bool Model::changeStopBits(uint8_t index)
{
    if( serial_port->setStopBits(QSerialPort::StopBits(index)) ){
        return true;
    }else{
        QString mes = "Error while changing port '" + serial_port->portName() + "' stop bits\nError description: " + serial_port->errorString();
        qDebug() << mes;
        emit emitAddText(mes);
        return false;
    }
}



bool Model::changeFlowControl(uint8_t index)
{
    QSerialPort::FlowControl f;
    switch (index){
    case 0:
        f = QSerialPort::FlowControl::NoFlowControl;
        break;
    case 1:
        f = QSerialPort::FlowControl::HardwareControl;
        break;
    case 2:
        f = QSerialPort::FlowControl::SoftwareControl;
        break;
    }
    if( serial_port->setFlowControl(f) ){
        return true;
    }else{
        QString mes = "Error while changing port '" + serial_port->portName() + "' flow control\nError description: " + serial_port->errorString();
        qDebug() << mes;
        emit emitAddText(mes);
        return false;
    }
}






bool Model::openClosePort(bool open)
{
    if(open){
        if(serial_port->isOpen())
            serial_port->close();
        if(serial_port->open(QSerialPort::ReadWrite)){
            emit updateStateLights(true);
            return true;
        }else{
            QString mes = "Error: error encountered while trying to open port: '" + serial_port->portName() + "'\n" + "Error description: " + serial_port->errorString();;
            qDebug() << mes;
            emit emitAddText(mes);
            return false;
        }
    }else{
        serial_port->close();
        emit updateStateLights(false);
        return true;
    }
}



bool Model::isPortOpen()
{
    return serial_port->isOpen();
}



void Model::getNewValueFromSerialPort()
{
    if(!serial_port->isOpen())
        return;

    QString data = serial_port->readAll();
    emit appendSerialData(data);

    if(data == "")
        return;

    int _index = data.indexOf("£$");
    while(_index != std::string::npos){
        uint16_t _tmp_index = data.indexOf("/", _index);

        QString _name = data.mid(_index + 2, _tmp_index - _index - 2);

        QPointF value( data.mid(_tmp_index + 1, data.indexOf(";", _tmp_index) - _tmp_index - 1).toDouble(),
                      data.mid(data.indexOf(";", _tmp_index) + 1, data.indexOf("$£", _tmp_index) - data.indexOf(";", _tmp_index) - 1).toDouble());


        if(lines.find(_name) == lines.end()){
            if(lines.size() == colors.size()){
                _index = data.indexOf("£$", _tmp_index);
                continue;
            }

            Lines* _l = new Lines();
            _l->name = _name;
            _l->color = getNewLineColor();
            lines.insert( std::pair<QString, Lines*>(_name, _l) );

            emit lineAdded(_name);
        }

        lines.at(_name)->points.push_back(value);
        emit updateLine(_name);

        _index = data.indexOf("£$", _tmp_index);
    }
    if(plot_following){
        followPlot();
    }else if(see_whole_curve){
        seeWholeCurve();
    }
}



bool Model::writeSerialData(QString s)
{
    if(!serial_port->isOpen()){
        QString mes = "The selected port: '" + serial_port->portName() + "' is currently close so no data can be send to it\n\n";
        qDebug() << mes;
        emit emitAddText(mes);
        return false;
    }

    serial_port->write(s.toStdString().c_str(), s.size());
    if(serial_port->flush())
        return true;
    else{
        QString mes = "Error encountered while trying to send the data\n\n";
        qDebug() << mes;
        emit emitAddText(mes);
        return false;
    }
}



void Model::changeXZoom(int32_t zoom)
{
    axis_zoom[0] = zoom;
    emit updateAxis();
}



void Model::changeYZoom(int32_t zoom)
{
    axis_zoom[1] = zoom;
    emit updateAxis();
}



void Model::zoomIn()
{
    if(axis_zoom[0] > zoom_limits[1] || axis_zoom[1] > zoom_limits[1])
        return;
    axis_zoom[0]++;
    axis_zoom[1]++;
    emit updateAxis();
    emit updateGraphControls();
}



void Model::zoomOut()
{
    if(axis_zoom[0] < zoom_limits[0] || axis_zoom[1] < zoom_limits[0])
        return;
    axis_zoom[0]--;
    axis_zoom[1]--;
    emit updateAxis();
    emit updateGraphControls();
}



std::vector<double> Model::getAxisZoom()
{
    return {axis_zoom[0], axis_zoom[1]};
}



std::vector<int32_t> Model::getZoomLimits()
{
    return {zoom_limits[0], zoom_limits[1]};
}




std::vector<double> Model::getXAxisLimits()
{
    return {axis_limits[0][0], axis_limits[0][1]};
}



std::vector<double> Model::getYAxisLimits()
{
    return {axis_limits[1][0], axis_limits[1][1]};
}



std::vector<double> Model::getZoomedXAxisLimits()
{
    if(axis_limits[0][0] + axis_zoom[0]*abs(axis_limits[0][0] - axis_limits[0][1]) < axis_limits[0][1] - axis_zoom[0]*abs(axis_limits[0][0] - axis_limits[0][1]))
        return {axis_limits[0][0] + axis_zoom[0]*abs(axis_limits[0][0] - axis_limits[0][1]), axis_limits[0][1] - axis_zoom[0]*abs(axis_limits[0][0] - axis_limits[0][1])};
    else
        return {(axis_limits[0][0] + axis_limits[0][1])/2 - MIN_DISTANCE_BETWEEN_AXIS_LIMITS, (axis_limits[0][0] + axis_limits[0][1])/2 + MIN_DISTANCE_BETWEEN_AXIS_LIMITS};
}



std::vector<double> Model::getZoomedYAxisLimits()
{
    if(axis_limits[1][0] + axis_zoom[1]*abs(axis_limits[1][1] - axis_limits[1][0]) < axis_limits[1][1] - axis_zoom[1]*abs(axis_limits[1][1] - axis_limits[1][0]))
        return {axis_limits[1][0] + axis_zoom[1]*abs(axis_limits[1][1] - axis_limits[1][0]), axis_limits[1][1] - axis_zoom[1]*abs(axis_limits[1][1] - axis_limits[1][0])};
    else
        return {(axis_limits[1][0] + axis_limits[1][1])/2 - MIN_DISTANCE_BETWEEN_AXIS_LIMITS, (axis_limits[1][0] + axis_limits[1][1])/2 + MIN_DISTANCE_BETWEEN_AXIS_LIMITS};
}



/*
 *changeXLimits(double, double)
 *  this function check all the required condition before calling the function
 *  modifyXLimits(double, double);
*/
void Model::changeXLimits(double new_min, double new_max)
{
    if(!plot_following && !see_whole_curve)
        modifyXLimits(new_min, new_max);
}



/*
 *changeYLimits(double, double)
 *  this function check all the required condition before calling the function
 *  modifyYLimits(double, double);
*/
void Model::changeYLimits(double new_min, double new_max)
{
    if(!plot_following && !see_whole_curve)
        modifyYLimits(new_min, new_max);
}



void Model::modifyXLimits(double new_min, double new_max)
{
    if(new_max - new_min >= MIN_DISTANCE_BETWEEN_AXIS_LIMITS){
        axis_limits[0][0] = new_min;
        axis_limits[0][1] = new_max;
        emit updateAxis();
    }
}



void Model::modifyYLimits(double new_min, double new_max)
{
    if(new_max - new_min >= MIN_DISTANCE_BETWEEN_AXIS_LIMITS){
        axis_limits[1][0] = new_min;
        axis_limits[1][1] = new_max;
        emit updateAxis();
    }
}



void Model::followPlot()
{
    if(lines.find(selected_line) == lines.end() || lines[selected_line]->points.size() == 0)
        return;
    modifyXLimits(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).x() + (axis_limits[0][1] - axis_limits[0][0])*OFFSET_PLOT_FOLLOW - (axis_limits[0][1] - axis_limits[0][0]), lines[selected_line]->points.at(lines[selected_line]->points.size()-1).x() + (axis_limits[1] - axis_limits[0])*OFFSET_PLOT_FOLLOW);
    modifyYLimits(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).y() - (axis_limits[1][1] - axis_limits[1][0])/2, lines[selected_line]->points.at(lines[selected_line]->points.size()-1).y() + (axis_limits[1][1] - axis_limits[1][0])/2);
}


void Model::setPlotFollowing(bool value)
{
    if(!value)
        plot_following = value;
    else if(!see_whole_curve && lines.find(selected_line) != lines.end()){
        plot_following = value;
        followPlot();
    }
}


bool Model::getPlotFollowing()
{
    return plot_following;
}



void Model::setShowPoints(bool value)
{
    show_points = value;
    emit showPointsChanged();
}


bool Model::getShowPoints()
{
    return show_points;
}


/*
 *seeWholeCurve()
 *
 *  IMPORTAT NOTE:
 *  This program wants to be a generic data plot, so it isn't sure that the data will be plotted
 *  as function of time. So the algorithm cant just see the first point of the series and the last
 *  one for determine the plot border, but it has to search for the min and the max x and y values
 *  in all the point of the vector
*/
void Model::seeWholeCurve()
{
    if(selected_line != "All" && (selected_line == "" || lines[selected_line]->points.size() == 0))
        return;


    if(selected_line == "All"){
        if(lines.size() == 0)
            return;

        double min[2] = {0,0};
        double max[2] = {0,0};

        bool only_empty_lines = true;

        for(auto& pair : lines){
            if(pair.second->points.size() == 0)
                continue;

            only_empty_lines = false;
            min[0] = pair.second->points.at(0).x();
            min[1] = pair.second->points.at(0).y();
            max[0] = pair.second->points.at(0).x();
            max[1] = pair.second->points.at(0).y();
        }

        if(only_empty_lines)
            return;

        for(auto& pair : lines){
            if(pair.second->points.size() == 0)
                continue;


            for(QPointF p : pair.second->points){
                if(p.x() < min[0])
                    min[0] = p.x();
                else if(p.x() > max[0])
                    max[0] = p.x();

                if(p.y() < min[1])
                    min[1] =p.y();
                else if(p.y() > max[1])
                    max[1] = p.y();
            }
        }
        modifyXLimits(min[0] - (max[0] - min[0])*0.8, max[0] + (max[0] - min[0])*1.2);
        modifyYLimits(min[1] - (max[1] - min[1])*0.8, max[1] + (max[1] - min[1])*1.2);
    }else{
        double min[2] = {0,0};
        double max[2] = {0,0};
        min[0] = lines[selected_line]->points.at(0).x();
        min[1] = lines[selected_line]->points.at(0).y();
        max[0] = lines[selected_line]->points.at(0).x();
        max[1] = lines[selected_line]->points.at(0).y();


        for(QPointF p : lines[selected_line]->points){
            if(p.x() < min[0])
                min[0] = p.x();
            else if(p.x() > max[0])
                max[0] = p.x();

            if(p.y() < min[1])
                min[1] =p.y();
            else if(p.y() > max[1])
                max[1] = p.y();
        }
        modifyXLimits(min[0] - (max[0] - min[0])*0.8, max[0] + (max[0] - min[0])*1.2);
        modifyYLimits(min[1] - (max[1] - min[1])*0.8, max[1] + (max[1] - min[1])*1.2);
    }
}




void Model::setSeeWholeCurve(bool value)
{
    if(!value)
        see_whole_curve = value;
    else if(!plot_following){
        see_whole_curve = value;
        seeWholeCurve();
    }
}


bool Model::getSeeWholeCurve()
{
    return see_whole_curve;
}



void Model::setSelectedLine(QString line_name)
{
    //the functionality "plot_following" cant, obviusly, work with evrey or none of the line
    //series, so if the user select All series or deselect every series the program has
    //to check if "plot_following" was activated, and, if it was the case, deactivate it
    if(line_name == "" || line_name == "All"){
        selected_line = line_name;
        setPlotFollowing(false);
        emit selectedLineChanged();

        return;
    }else if(lines.find(line_name) != lines.end()){
        selected_line = line_name;

        emit selectedLineChanged();
    }
}


QString Model::getSelectedLine()
{
    return selected_line;
}


//to modify, since lines is now a map
void Model::clearLine()
{
    if(selected_line == "")
        return;

    if(selected_line == "All"){
        for(auto& p : lines){
            p.second->points.clear();
        }

        emit refreshLine();
        return;
    }

    lines[selected_line]->points.clear();

    emit refreshLine();
}


QString Model::getNewLineColor()
{
    if(lines.size() >= colors.size())
        return "";

    return colors[lines.size() - 1];
}
