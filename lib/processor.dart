import 'dart:io';

import 'package:ansicolor/ansicolor.dart';

class Processor {
  String executable;
  List<String> arguments;
  String workingDirectory;

  Processor({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
  });

  dynamic run() async {
    final greenPen = AnsiPen()..green();
    final redPen = AnsiPen()..red(bold: true);
    final bluePen = AnsiPen()..blue();

    var result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );

    if (result.stdout.toString().trim().isNotEmpty) {
      stdout.writeln(greenPen(result.stdout));
    }

    if (result.stderr.toString().trim().isNotEmpty) {
      if (result.stderr.toString().trim().toLowerCase().contains("warning")) {
        stderr.writeln(bluePen(result.stderr));
      } else {
        stderr.writeln(redPen(result.stderr));
      }
    }
  }
}
