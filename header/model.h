#ifndef MODEL_H
#define MODEL_H


#include <iostream>
#include <string>
#include <limits>
#include <array>

#include <QObject>
#include <QtSerialPort/QSerialPort>
#include <QtSerialPort/QSerialPortInfo>
#include <QDebug>
#include <QPoint>


#define MIN_DISTANCE_BETWEEN_AXIS_LIMITS 0.0009
#define OFFSET_SEE_WHOLE_CURVE 0.1
#define ZOOM_CONSTANT 0.01


//PATTERN =  £$name/x_value;y_value$£

class Model : public QObject
{
    Q_OBJECT

public:
    explicit Model(QObject *parent = nullptr);
    ~Model();

    Q_INVOKABLE std::vector<QPointF> getLine(QString name);
    Q_INVOKABLE inline QString getLineColor(QString name) {return lines.at(name)->color;}
    Q_INVOKABLE void clearLine();
    Q_INVOKABLE void removeLine();
    Q_INVOKABLE void setVisibilityOfSelectedSeries(bool visible);
    Q_INVOKABLE bool getVisibilityOfSeries(QString name);

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

    Q_INVOKABLE void setSelectedLine(QString line_name);
    Q_INVOKABLE QString getSelectedLine();

    Q_INVOKABLE inline double getMinDistanceBetweenAxisLimits() const {return MIN_DISTANCE_BETWEEN_AXIS_LIMITS;}

private:
    struct Lines{
        std::vector<QPointF> points;
        QString name, color;
        bool visible = true;
    };


    QSerialPort* serial_port;

    std::map<QString, Lines*> lines;
    QString selected_line;

    //The colors array dictate the maximum lines that the program can handle.
    //so if you want to increase the possible lines just add some color in here
    std::array<QString ,8> colors{"#ff4444", "#44ff44", "#4444ff",
                                  "#ffbf00", "#ff22ff", "#93c572",
                                  "adadad", "#a95c68"};

    double axis_limits[2][2] = {{-5,5}, {-5,5}};

    static constexpr int32_t zoom_limits[] = {-100, 100};
    double axis_zoom[2] = {0, 0};

    bool see_whole_curve = false;
    bool plot_following = false;
    bool show_points = false;

    QString getNewLineColor();

    void modifyXLimits(double new_min, double new_max);
    void modifyYLimits(double new_min, double new_max);

    void modifyZoomedXLimits(double new_min, double new_max);
    void modifyZoomedYLimits(double new_min, double new_max);

    void followPlot();
    void seeWholeCurve();

signals:
    void emitAddText(QString new_text);
    void portStateChanged(bool port_opened);

    void appendSerialData(QString serial_data);

    void showPointsChanged();

    void updateAxis();
    void updateGraphControls();

    void updateLine(QString line_name);
    void lineAdded(QString line_name);
    void selectedLineChanged();
    void refreshLine();

    void lineRemoved(QString line_name);

    void plotFollowingChanged();
    void seeWholeCurveChanged();

    void changeSeriesVisibility(QString series_name);

public slots:
    void getNewValueFromSerialPort();
};

#endif // MODEL_H
