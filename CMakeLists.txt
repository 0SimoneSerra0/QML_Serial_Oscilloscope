cmake_minimum_required(VERSION 3.16)

project(Oscilloscope VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick SerialPort)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appOscilloscope
    src/main.cpp
    header/model.h
    src/model.cpp
)

qt_add_qml_module(appOscilloscope
    URI Oscilloscope
    VERSION 1.0

QML_FILES
    src/qml/CustomDial.qml
    src/qml/CustomLineSeries.qml
    src/qml/CustomTextEdit.qml
    src/qml/ErrorTerminal.qml
    src/qml/Graph.qml
    src/qml/GraphControls.qml
    src/qml/LabelPointCoordinates.qml
    src/qml/Main.qml
    src/qml/scripts.js
    src/qml/SerialIOInterface.qml
    src/qml/SerialPortOption.qml
    src/qml/LineSelectorElement.qml
    src/qml/CustomMouseArea.qml
    QML_FILES src/qml/CustomComboBox.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appOscilloscope PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appOscilloscope
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appOscilloscope
    PRIVATE Qt6::Quick
    PRIVATE Qt6::SerialPort
)

include(GNUInstallDirs)
install(TARGETS appOscilloscope
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
