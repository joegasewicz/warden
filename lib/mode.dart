import 'dart:io';

import 'package:ansicolor/ansicolor.dart';

class Mode {
  String? mode;
  final greenPen = AnsiPen()..green();
  final redPen = AnsiPen()..red(bold: true);
  final bluePen = AnsiPen()..blue();
  final yellowPen = AnsiPen()..yellow(bold: true);

  Mode({required this.mode}) {
    if (mode == null) {
      mode = "development";
      print(yellowPen("⚠️no mode set. Setting to 'development' environment."));
    } else {
      switch(mode) {
        case "development":
          print(greenPen("🧪mode set to 'development' environment."));
          break;
        case "production":
          print(greenPen("🚀mode set to 'production' environment"));
          break;
        default:
          print(redPen("❌fatal error: Mode must be set to either 'production' or 'development'!"));
          exit(1);
      }
    }
  }

  @override
  String toString() {
    return "Mode(mode: $mode)";
  }
}