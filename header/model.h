#ifndef MODEL_H
#define MODEL_H

#include <QObject>
#include <iostream>
#include <QtSerialPort/QSerialPort>
#include <QtSerialPort/QSerialPortInfo>
#include <QDebug>
#include <string>
#include <limits>
#include <QPoint>


#define MIN_DISTANCE_BETWEEN_AXIS_LIMITS 0.0009
#define OFFSET_PLOT_FOLLOW 0.1

//PATTERN =  £$name/x_value;y_value$£

class Model : public QObject
{
    Q_OBJECT

public:
    explicit Model(QObject *parent = nullptr);
    ~Model();

    Q_INVOKABLE inline std::vector<QPointF> getLine() {return lines;}
    Q_INVOKABLE void clearLine();

    Q_INVOKABLE static std::vector<QString> getAllAvailablePortName();
    Q_INVOKABLE static std::vector<uint32_t> getCommonBaudRates();
    Q_INVOKABLE static std::vector<QString> getPossibleParity();
    Q_INVOKABLE static std::vector<QString> getPossibleStopBits();
    Q_INVOKABLE static std::vector<QString> getPossibleFlowControls();

    Q_INVOKABLE int changePort(uint16_t port_index);
    Q_INVOKABLE bool changeBaudRate(uint8_t index);
    Q_INVOKABLE bool changeDataBits(uint8_t new_value);
    Q_INVOKABLE bool changeParity(uint8_t index);
    Q_INVOKABLE bool changeStopBits(uint8_t index);
    Q_INVOKABLE bool changeFlowControl(uint8_t index);


    Q_INVOKABLE bool openClosePort(bool open);
    Q_INVOKABLE bool isPortOpen();

    Q_INVOKABLE bool writeSerialData(QString s);


    Q_INVOKABLE void changeXZoom(int32_t zoom);
    Q_INVOKABLE void changeYZoom(int32_t zoom);

    Q_INVOKABLE void zoomIn();
    Q_INVOKABLE void zoomOut();

    Q_INVOKABLE std::vector<double> getAxisZoom();
    Q_INVOKABLE static std::vector<int32_t> getZoomLimits();


    Q_INVOKABLE std::vector<double> getXAxisLimits();
    Q_INVOKABLE std::vector<double> getYAxisLimits();

    Q_INVOKABLE std::vector<double> getZoomedXAxisLimits();
    Q_INVOKABLE std::vector<double> getZoomedYAxisLimits();

    Q_INVOKABLE void changeXLimits(double new_min, double new_max);
    Q_INVOKABLE void changeYLimits(double new_min, double new_max);


    Q_INVOKABLE void setPlotFollowing(bool value);
    Q_INVOKABLE bool getPlotFollowing();

    Q_INVOKABLE void setShowPoints(bool value);
    Q_INVOKABLE bool getShowPoints();

    Q_INVOKABLE void setSeeWholeCurve(bool value);
    Q_INVOKABLE bool getSeeWholeCurve();

    Q_INVOKABLE inline double getMinDistanceBetweenAxisLimits() const {return MIN_DISTANCE_BETWEEN_AXIS_LIMITS;}

private:
    std::vector<QPointF> lines;

    QSerialPort* serial_port;

    double axis_limits[2][2] = {{0,10}, {0,10}};

    static constexpr int32_t zoom_limits[] = {-100, 100};
    double axis_zoom[2] = {0, 0};

    bool see_whole_curve = false;
    bool plot_following = true;
    bool show_points = false;

    void modifyXLimits(double new_min, double new_max);
    void modifyYLimits(double new_min, double new_max);

    void follow_plot();
    void seeWholeCurve();

signals:
    void emitAddText(QString new_text);
    void portChanged(bool port_opened);
    void updateStateLights(bool port_opened);

    void appendSerialData(QString serial_data);

    void showPointsChanged();

    void updateAxis();
    void updateGraphControls();

    void updateLine();
    void refreshLine();

public slots:
    void getNewValueFromSerialPort();
};

#endif // MODEL_H
