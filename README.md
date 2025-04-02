# QML_Serial_Oscilloscope
A completely open source project of a **serial plotter**, resembling the appearence of an oscilloscope, made using QML together with C++.
This program plot real time data recived from serial ports on a graph. It can be usefull if is needed a controllable way to analyze information took by an external source, like a microcontroller.<br>
<br>
<br>
<br>
## Build
At the moment the builds that i have tested were made using QtCreator or qt-cmake, an executable contained in Qt. Both ways requires the Qt framework installed on the building machine.<br>
(The dependencies could be incomplete, so if you find a problem with them please inform me)
<br>
<br>
### Linux<br>
##
<br>
<br>

**DEPENDENCIES**<br>
- Debian<br>

```sudo apt install libqt6serialport6 libqt6qml6 libqt6gui6 libglx0 libopengl0 libqt6core6 libstdc++-11-dev libc6 libgcc-s1 libpthreadpool0 libqt6network6 libdlib-dev libegl1 libfontconfig1 libx11-6 libglib2.0-0 libqt6dbus6 libxkbcommon0 libgl1 libz3-4 libfreetype6 libicu72```

<br>

**Build step**

```
cd QML_Serial_Oscilloscope/

mkdir build && cd build

~/Qt/<QT_VERSION>/gcc_64/bin/qt-cmake ..

cmake --build .
```

<br>
<br>
<br>

## Feature
This project let the user plot real time data coming from a serial port. This could be handy it's needed the visualization of data coming from an external source, like an arduino or a raspberry pi.<br>
In the actual version of the project the main feature are:

- Various **options** for the **serial port**;
- An interface for **writing** to, and **reading** from the serial port;
- **Axis zoom**, that let the user go around in the graph while giving him an easy way to **come back** at the **initial point**;
- Easy **graph movment** using the **mouse**, and wheel or **trackpad**, directly **on** the graph. All the displacment can be **manually set** and modified from an UI in the bottom left of the controls part;
- An option that let the user **follow the plot**, one that makes **visible the whole curve**, another that makes the graph come back to the **initial condition**, one that **clear all the data** recived and another that physically remove all the information recived of the selected series;
- A virtual switch that **highlight** the actual **point** of the series. Each point is **clickable** and makes pop a litle dialog with its **coordinates**, and a button that let the user hide specifics series.
- **Multi channeling**. The program can plot up to 8 curves of data on the same graph. This number is easely customizable by modifying the 'colors' array in src/model.h, because is its size that determine the maximum number of line series on the plot.
- An interface to **select** a specific series or all the series. To use all the function of the program with each curve there is a litle list of clickable button just under the graph.
- An 'hide controls' fnction to let the actual graoh occupy more space
<br>
<br>
<br>

## Usage
The usage is very simple: **set the serial port** with its paramenter and **open** it, when the serial data arrives it will be plotted on the graph.
In order to identify the wanted data between all the other comunication this program reads only a specific pattern:<br>
**£$name/x_value;y_value$£**<br>
**IMPORTANT**: there are only two invalid name: "All" and "". If you'll try to plot a series with one of these names the program will ignore it.
<br>
<br>
<br>

## Screenshots
<br>

<br>

![assets/Video1.gif](/assets/Video1.gif)

<br>

![assets/Video2.gif](/assets/Video2.gif)

<br>
<br>
<br>

### Arduino sketch for testing the program
```
void setup() {
  Serial.begin(9600);
}

double x = 0;
double _y1 = sin(x);
double _y2 = cos(x);

void loop() {
  Serial.println("£$Sin(x)/" + String(x) + ";" + String(_y1) + "$£");
  Serial.println("£$Cos(x)/" + String(x) + ";" + String(_y2) + "$£");

  x += 0.1;
  _y1 = sin(x);
  _y2 = cos(x);

  delay(50);
}


```
