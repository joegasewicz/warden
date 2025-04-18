import 'dart:io';

import 'package:ansicolor/ansicolor.dart';

/// A class that runs shell commands from within a Dart application.
///
/// The `Processor` is used to execute CLI commands such as compiling Dart
/// to JavaScript or running Sass. It prints the command output in color:
/// - Green for standard output
/// - Blue for warnings
/// - Red for errors
///
/// Example:
/// ```dart
/// final processor = Processor(
///   executable: 'dart',
///   arguments: ['compile', 'js', 'bin/main.dart', '-o', 'build/main.js'],
///   workingDirectory: 'frontend',
/// );
/// await processor.run();
/// ```
class Processor {
  String executable;
  List<String> arguments;
  String workingDirectory;
  bool warnings;
  String name;

  Processor({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
    required this.warnings,
    required this.name,
  });

  /// Executes the configured command and prints stdout and stderr
  /// with colored formatting.
  ///
  /// - Green for success output
  /// - Blue for warnings
  /// - Red for errors
  ///
  /// The method returns a [Future] that completes after the command runs.
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
      stdout.writeln(greenPen("[WARDEN]: ✅[TASK $name]: ${result.stdout}"));
    }

    if (result.stderr.toString().trim().isNotEmpty) {
      final containsWarning =
          result.stderr.toString().trim().toLowerCase().contains("warning");
      final containsError =
          result.stderr.toString().trim().toLowerCase().contains("Error");
      if (containsWarning && !containsError) {
        if (warnings) {
          stderr.writeln(bluePen("[WARDEN]: ⚠️[TASK $name]: ${result.stderr}"));
        } else {
          print(greenPen(
              "[WARDEN]: ✅[TASK $name]: Successfully ran task for: $name"));
        }
      } else {
        stderr.writeln(redPen("[WARDEN]: ⛔[TASK $name]: ${result.stderr}"));
      }
    }
  }
}
