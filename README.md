# envel-flutter

A new Flutter project.

## Getting Started
Remember to run  `flutter pub get`

### Running in web
#### doesn't seem to work on windows :(
* Add `--web-port=9091` to run command
    * In intellij -> dropdown on `main.dart` in top right corner -> Edit  configurations -> additional run args
* Create an nginx proxy with the docker-compose inside `web/proxy`

* Run flutter and change the browser url to port 9090
* _If running in IntelliJ the console output and debugger should work as expected_