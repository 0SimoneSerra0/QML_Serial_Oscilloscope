cmake_minimum_required(VERSION 3.16)

project(Oscilloscope VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick SerialPort)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appOscilloscope
    main.cpp
    model.h
    model.cpp
)

qt_add_qml_module(appOscilloscope
    URI Oscilloscope
    VERSION 1.0
    QML_FILES Main.qml ErrorTerminal.qml SerialPortOption.qml Graph.qml
    QML_FILES SerialIOInterface.qml
    QML_FILES GraphControls.qml
    QML_FILES CustomDial.qml
    QML_FILES scripts.js
    QML_FILES LabelPointCoordinates.qml
    QML_FILES CustomLineSeries.qml
    QML_FILES CustomTextEdit.qml
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
