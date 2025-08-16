import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';

class Mode {
  String? mode;
  Mode({required this.mode}) {
    if (mode == null) {
      mode = "development";
      print(AnsiStyles.yellow(
          "⚠ no mode set. Setting to 'development' environment."));
    } else {
      switch (mode) {
        case "development":
          print(
              "${AnsiStyles.cyan("◆ mode set to")} ${AnsiStyles.magentaBright("[development]")} ${AnsiStyles.cyan("environment")}");
          break;
        case "production":
          print(
              "${AnsiStyles.cyan("◆ mode set to")} ${AnsiStyles.magentaBright("[production]")} ${AnsiStyles.cyan("environment")}");
          break;
        default:
          print(AnsiStyles.red(
              "✖ fatal error: Mode must be set to either 'production' or 'development'!"));
          exit(1);
      }
    }
  }

  @override
  String toString() {
    return "Mode(mode: $mode)";
  }
}
