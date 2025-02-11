#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include "header/model.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    Model* m = new Model(&app);

    qmlRegisterSingletonInstance<Model>("MyModel", 1, 0, "Model", m);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Oscilloscope", "Main");

    app.setWindowIcon(QIcon(":/icons/assets/Icon.png"));

    return app.exec();
}
