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
    emit portStateChanged(false);
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
            emit portStateChanged(true);
            return true;
        }else{
            QString mes = "Error: error encountered while trying to open port: '" + serial_port->portName() + "'\n" + "Error description: " + serial_port->errorString();;
            qDebug() << mes;
            emit emitAddText(mes);
            return false;
        }
    }else{
        serial_port->close();
        emit portStateChanged(false);
        return true;
    }
}



bool Model::isPortOpen()
{
    return serial_port->isOpen();
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
        if(_name == "All" || _name == "")
            continue;

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
    double min = axis_limits[0][0] + (ZOOM_CONSTANT*axis_zoom[0])*(axis_limits[0][1] - axis_limits[0][0]);
    double max = axis_limits[0][1] - (ZOOM_CONSTANT*axis_zoom[0])*(axis_limits[0][1] - axis_limits[0][0]);

    if(min < max - MIN_DISTANCE_BETWEEN_AXIS_LIMITS){
        return {min, max};
    }else
        return {(axis_limits[0][0] + axis_limits[0][1])/2 - MIN_DISTANCE_BETWEEN_AXIS_LIMITS,
                (axis_limits[0][0] + axis_limits[0][1])/2 + MIN_DISTANCE_BETWEEN_AXIS_LIMITS};
}



std::vector<double> Model::getZoomedYAxisLimits()
{
    double min = axis_limits[1][0] + (ZOOM_CONSTANT*axis_zoom[1])*(axis_limits[1][1] - axis_limits[1][0]);
    double max = axis_limits[1][1] - (ZOOM_CONSTANT*axis_zoom[1])*(axis_limits[1][1] - axis_limits[1][0]);

    if(min < max - MIN_DISTANCE_BETWEEN_AXIS_LIMITS){
        return {min, max};
    }else
        return {(axis_limits[1][0] + axis_limits[1][1])/2 - MIN_DISTANCE_BETWEEN_AXIS_LIMITS,
                (axis_limits[1][0] + axis_limits[1][1])/2 + MIN_DISTANCE_BETWEEN_AXIS_LIMITS};
}



/*
 *changeXLimits(double, double)
 *  this function check all the required condition before calling the function
 *  modifyXLimits(double, double);
*/
void Model::changeXLimits(double new_min, double new_max)
{
    if(plot_following)
        if(lines[selected_line]->points.size() > 0){
            //IMPORTANT: if you modify the zoom system you also havo to modify the next line
            double zoom = (ZOOM_CONSTANT*axis_zoom[0])*(axis_limits[0][1] - axis_limits[0][0]);
            modifyXLimits(new_min < lines[selected_line]->points.at(lines[selected_line]->points.size() - 1).x() - zoom? new_min : lines[selected_line]->points.at(lines[selected_line]->points.size() - 1).x() - zoom,
                          new_max > lines[selected_line]->points.at(lines[selected_line]->points.size() - 1).x() + zoom? new_max : lines[selected_line]->points.at(lines[selected_line]->points.size() - 1).x() + zoom);
        }else
            modifyXLimits(new_min, new_max);
    else if(!see_whole_curve)
        modifyXLimits(new_min, new_max);
}



/*
 *changeYLimits(double, double)
 *  this function check all the required condition before calling the function
 *  modifyYLimits(double, double);
*/
void Model::changeYLimits(double new_min, double new_max)
{
    if(plot_following)
        if(lines[selected_line]->points.size() > 0)
            modifyYLimits(new_min + (ZOOM_CONSTANT*axis_zoom[1])*(axis_limits[1][1] - axis_limits[1][0]) < lines[selected_line]->points.at(lines[selected_line]->points.size() - 1).y() ? new_min : axis_limits[1][0], new_max + (ZOOM_CONSTANT*axis_zoom[1])*(axis_limits[1][1] - axis_limits[1][0]) > lines[selected_line]->points.at(lines[selected_line]->points.size() - 1).y() ? new_max : axis_limits[1][1]);
        else
            modifyYLimits(new_min, new_max);
    else if(!see_whole_curve)
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



void Model::modifyZoomedXLimits(double zoomed_min, double zoomed_max){
    /*IMPORTANT:
     * if you modify getZoomedXAxisLimits() you probably will hate to modify also the
     * next lines. that equation are obtained from the system:
     *
     * { zoomed_min_value = DEZOOMED_MIN_VALUE - (_zoom*(DEZOOMED_MAX_VALUE - DEZOOMED_MIN_VALUE))
     * { zoomed_max_value = DEZOOMED_MAX_VALUE + (_zoom*(DEZOOMED_MAX_VALUE - DEZOOMED_MIN_VALUE))
    */
    double _zoom = (ZOOM_CONSTANT*axis_zoom[0]);

    if(_zoom == 1 || _zoom == 0)
        _zoom += 0.0000001;

    double dezoomed_max = (zoomed_max*(1 - _zoom) - _zoom*zoomed_min)/(1 - 2*_zoom);
    double dezoomed_min = (zoomed_min - _zoom*dezoomed_max)/( 1 - _zoom );


    modifyXLimits(dezoomed_min, dezoomed_max);
}



void Model::modifyZoomedYLimits(double zoomed_min, double zoomed_max)
{
    /*IMPORTANT:
     * if you modify getZoomedYAxisLimits() you probably will hate to modify also the
     * next three line. that equation are obtained from the system:
     *
     * { zoomed_min_value = DEZOOMED_MIN_VALUE - (_zoom*(DEZOOMED_MAX_VALUE - DEZOOMED_MIN_VALUE))
     * { zoomed_max_value = DEZOOMED_MAX_VALUE + (_zoom*(DEZOOMED_MAX_VALUE - DEZOOMED_MIN_VALUE))
    */
    double _zoom = (ZOOM_CONSTANT*axis_zoom[1]);

    if(_zoom == 1 || _zoom == 0)
        _zoom += 0.0000001;

    double dezoomed_max = (zoomed_max*(1 - _zoom) - _zoom*zoomed_min)/(1 - 2*_zoom);
    double dezoomed_min = (zoomed_min - _zoom*dezoomed_max)/( 1 - _zoom );


    modifyYLimits(dezoomed_min, dezoomed_max);
}


void Model::followPlot()
{
    if(lines[selected_line]->points.size() == 0 || lines.find(selected_line) == lines.end())
        return;

    if(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).x() > getZoomedXAxisLimits()[1])
        modifyZoomedXLimits(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).x() - (getZoomedXAxisLimits()[1] - getZoomedXAxisLimits()[0]), lines[selected_line]->points.at(lines[selected_line]->points.size()-1).x());
    else if(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).x() < getZoomedXAxisLimits()[0])
        modifyZoomedXLimits(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).x(), lines[selected_line]->points.at(lines[selected_line]->points.size()-1).x() + (getZoomedXAxisLimits()[1] - getZoomedXAxisLimits()[0]));


    if(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).y() > getZoomedYAxisLimits()[1])
        modifyZoomedYLimits(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).y() - (getZoomedYAxisLimits()[1] - getZoomedYAxisLimits()[0]), lines[selected_line]->points.at(lines[selected_line]->points.size()-1).y());
    else if(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).y() < getZoomedYAxisLimits()[0])
        modifyZoomedYLimits(lines[selected_line]->points.at(lines[selected_line]->points.size()-1).y(), lines[selected_line]->points.at(lines[selected_line]->points.size()-1).y() + (getZoomedYAxisLimits()[1] - getZoomedYAxisLimits()[0]));
}


void Model::setPlotFollowing(bool value)
{
    if(!value){
        plot_following = value;
        emit plotFollowingChanged();
    }else if(lines.find(selected_line) != lines.end()){
        if(see_whole_curve)
            setSeeWholeCurve(false);
        plot_following = value;
        emit plotFollowingChanged();
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
        modifyZoomedXLimits(min[0] - (max[0] - min[0])*OFFSET_SEE_WHOLE_CURVE, max[0] + (max[0] - min[0])*OFFSET_SEE_WHOLE_CURVE);
        modifyZoomedYLimits(min[1] - (max[1] - min[1])*OFFSET_SEE_WHOLE_CURVE, max[1] + (max[1] - min[1])*OFFSET_SEE_WHOLE_CURVE);
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
        modifyZoomedXLimits(min[0] - (max[0] - min[0])*OFFSET_SEE_WHOLE_CURVE, max[0] + (max[0] - min[0])*OFFSET_SEE_WHOLE_CURVE);
        modifyZoomedYLimits(min[1] - (max[1] - min[1])*OFFSET_SEE_WHOLE_CURVE, max[1] + (max[1] - min[1])*OFFSET_SEE_WHOLE_CURVE);
    }
}






void Model::setSeeWholeCurve(bool value)
{
    if(!value){
        see_whole_curve = value;
        emit seeWholeCurveChanged();
    }else if(selected_line != ""){
        if(plot_following)
            setPlotFollowing(false);
        see_whole_curve = value;
        emit seeWholeCurveChanged();
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
    if(line_name == ""){
        selected_line = line_name;
        setSeeWholeCurve(false);
        setPlotFollowing(false);

        emit selectedLineChanged();
        return;
    }else if(line_name == "All"){
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

void Model::removeLine()
{
    emit lineRemoved(selected_line);

    if(selected_line == "All"){
        for(auto& p : lines){
            delete p.second;
            p.second = nullptr;
        }
        lines.clear();
        setPlotFollowing(false);
        setSeeWholeCurve(false);
        selected_line = "";
        emit selectedLineChanged();
        return;
    }else if(lines.find(selected_line) == lines.end()){
        return;
    }else{
        delete lines[selected_line];
        lines[selected_line] = nullptr;

        lines.erase(lines.find(selected_line));
        setSeeWholeCurve(false);
        setPlotFollowing(false);
        selected_line = "";
        emit selectedLineChanged();
    }
}



void Model::setVisibilityOfSelectedSeries(bool visible)
{
    if(selected_line == "")
        return;

    if(selected_line == "All")
        for(auto& p : lines){
            p.second->visible = visible;
        }
    else if(lines.find(selected_line) != lines.end())
        lines.at(selected_line)->visible = visible;

    emit changeSeriesVisibility(selected_line);
}



bool Model::getVisibilityOfSeries(QString name)
{
    if(name == "")
        return false;

    if(name == "All"){
        for(auto& p : lines){
            if(p.second->visible)
                return true;
        }
        return false;
    }else if(lines.find(name) != lines.end()){
        return lines.at(name)->visible;
    }
}



std::vector<QPointF> Model::getLine(QString name)
{
    if(lines.find(name) != lines.end())
        return lines.at(name)->points;
    else
        return std::vector<QPointF>();
}



QString Model::getNewLineColor()
{
    if(lines.size() >= colors.size())
        return "";

    QString color = "";
    for(int i = 0; i < colors.size(); ++i){
        int c = 0;
        for(auto& l : lines){
            c++;
            if(colors[i] == l.second->color)
                break;
            else if(c == lines.size()){
                color = colors[i];
                return color;
            }
        }
        if(c == 0){
            color = colors[i];
            break;
        }
    }

    return color;
}
