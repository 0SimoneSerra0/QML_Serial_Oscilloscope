# QML_Serial_Oscilloscope
It's a **serial plotter**, resembling the appearence of an oscilloscope, made using QML together with C++.
<br>
<br>
<br>
## Build
At the moment the builds that i have tested were made using QtCreator or qt-cmake, an executable contained in Qt. Both ways requires the Qt Framework installed on the building machine.<br>
(i'm struggling at making an exact list of the dependencies, so, at the moment, you can obtain the QtQuick packages and QSerialPort one using the Qt Maintenance tool, installed with the framework)
<br>
### Linux
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
- An option that let the user **follow the plot**, one that makes **visible the whole curve**, another that makes the graph come back to the **initial condition** and one that **clear all the data** recived;
- A virtual switch that **highlight** the actual **point** of the series. Each point is **clickable** and makes pop a litle dialog with its **coordinates**.
<br>
<br>
<br>

## ToDo List
- add an icon
- Tidying the code, making more comment explaining which code does what so that anyone can easely modify and customize the program;
- Implement a way to handle multiple series plot and makes it coherent with all the other function;
- making the UI look nicer.
<br>
<br>
<br>

## Usage
The usage is very simple: **set the serial port** with its paramenter and **open** it, when the serial data arrives it will be plotted on the graph.
In order to identify the wanted data between all the other comunication this program reads only a specific pattern:<br>
**£$name/x_value;y_value$£**<br>
At the moment the name part is useless but it will use in future version where there will be more lines at one time.
<br>
<br>
<br>

## Screenshots
![Screenshot_1](https://github.com/user-attachments/assets/6d349fcd-8e54-4b86-99b8-c4eeae298960)
<br>
![Screenshot_2](https://github.com/user-attachments/assets/d1ce2749-4ac2-4bc1-9a41-69dd0303b80f)
<br>
<br>
<br>

### Arduino sketch for testing the program
```
void setup() {
  Serial.begin(9600);
}

double x = 0;
double y = sin(x);

void loop() {
  Serial.println("£$name/" + String(x) + ";" + String(y) + "$£");

  x += 0.2;
  y = sin(x);
  delay(100);
}

```
