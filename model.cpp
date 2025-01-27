#include "model.h"

Model::Model(QObject *parent)
    : QObject{parent}
{
    serial_port = new QSerialPort(this);
}



Model::~Model(){
    if(serial_port->isOpen())
        serial_port->close();
}



/*
 *getAllAvailablePortName():
 *retuns a vector of QString containing all the accessible serial port in
 *the computer
*/
std::vector<QString> Model::getAllAvailablePortName(){
    std::vector<QString> p_names;

    for(QSerialPortInfo p : QSerialPortInfo::availablePorts()){
        p_names.push_back(p.portName());
    }

    return p_names;
}



/*
 *changePort(uint16_t)
 *Open a serial port given the index of it in the vector returned by the function
 *getAllAvailablePortName
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

std::vector<uint32_t> Model::getCommonBaudRates()
{
    return {110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200, 128000, 256000};
}

bool Model::changeDataBits(uint8_t new_value)
{
    return serial_port->setDataBits(QSerialPort::DataBits(new_value));
}

bool Model::changeParity(uint8_t index)
{
    return serial_port->setParity( index == 0 ? QSerialPort::Parity(index) : QSerialPort::Parity(index + 1) );
}

std::vector<QString> Model::getPossibleParity()
{
    return {"Parity None", "Parity Odd", "Parity Even", "Parity Mark", "Parity Space"};
}

std::vector<QString> Model::getPossibleStopBits()
{
    return {"One Stop", "Two Stop", "One and half Stop"};
}

bool Model::changeStopBits(uint8_t index)
{
    return serial_port->setStopBits(QSerialPort::StopBits(index));
}

std::vector<QString> Model::getPossibleFlowControls()
{
    return {"No flow control", "Hardware flow control", "Software flow control"};
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
    return serial_port->setFlowControl(f);
}

bool Model::isPortOpen()
{
    return serial_port->isOpen();
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



void Model::changeXZoom(int32_t zoom)
{
    zoom/=10;

    axis_zoom[0] = zoom;
    emit updateAxis();
}

void Model::changeYZoom(int32_t zoom)
{
    zoom/=10;

    axis_zoom[1] = zoom;
    emit updateAxis();
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

std::vector<double> Model::getAxisZoom()
{
    return {axis_zoom[0], axis_zoom[1]};
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

std::vector<int32_t> Model::getZoomLimits()
{
    return {zoom_limits[0], zoom_limits[1]};
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

        //std::string _name = data.substr(_index, _tmp_index);  //for now is useless, but it will be important for a future update


        QPointF value( data.mid(_tmp_index + 1, data.indexOf(";", _tmp_index) - _tmp_index - 1).toDouble(),
                     data.mid(data.indexOf(";", _tmp_index) + 1, data.indexOf("$£", _tmp_index) - data.indexOf(";", _tmp_index) - 1).toDouble());

        lines.push_back(value);
        emit updateLine();

        _index = data.indexOf("£$", _tmp_index);
    }
    if(plot_following){
        follow_plot();
    }else if(see_whole_curve){
        seeWholeCurve();
    }
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

void Model::follow_plot()
{
    if(lines.size() == 0)
        return;
    modifyXLimits(lines.at(lines.size()-1).x() + (axis_limits[0][1] - axis_limits[0][0])*OFFSET_PLOT_FOLLOW - (axis_limits[0][1] - axis_limits[0][0]), lines.at(lines.size()-1).x() + (axis_limits[1] - axis_limits[0])*OFFSET_PLOT_FOLLOW);
    modifyYLimits(lines.at(lines.size()-1).y() - (axis_limits[1][1] - axis_limits[1][0])/2, lines.at(lines.size()-1).y() + (axis_limits[1][1] - axis_limits[1][0])/2);
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

void Model::setPlotFollowing(bool value)
{
    if(!value)
        plot_following = value;
    else if(!see_whole_curve){
        plot_following = value;
        follow_plot();
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

void Model::seeWholeCurve()
{
    if(lines.size() == 0)
        return;
    double min[2] = {0,0};
    double max[2] = {0,0};
    min[0] = lines.at(0).x();
    min[1] = lines.at(0).y();
    max[0] = lines.at(0).x();
    max[1] = lines.at(0).y();
    for(QPointF p : lines){
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
