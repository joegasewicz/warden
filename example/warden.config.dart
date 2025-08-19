import 'dart:isolate';

Map<String, dynamic> config = {
  "sourceDir": "example",
  "mode": "development",
  "destination": "example/static",
  "mainFile": "example/static/main.js",
  "dependencies":  [
    "bootstrap/dist/js/bootstrap.min.js",
    "bootstrap/scss/bootstrap.scss",
  ],
  "assets": {
    "source": "examples/assets",
    "directories": ["img"],
    "compress": {
      "quality": 70,
    },
  },
  "tasks": [
    {
      "frontend": {
        "executable": "dart",
        "args": ["compile", "js", "bin/main.dart", "-O4", "-o", "static/main.js"],
        "src": "example",
      }
    },
    {
      "styles": {
        "executable": "dart",
        "args": ["run", "sass", "sass/index.scss:static/index.css"],
        "src": "example",
      }
    },
  ],
  "environment": {
   "dev": {
      "API_URL": "http://localhost:1234/api/v1",
    },
    "prod": {

    }
  },
};

void main(List<String> args, Object? message) {
  final sendPort = message as SendPort;
  sendPort.send(config);
}