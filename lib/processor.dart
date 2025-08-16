import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:cli_spinner/cli_spinner.dart';
import 'package:logging/logging.dart';
import 'package:warden/environment.dart';
import 'package:warden/exceptions.dart';
import 'package:warden/logger.dart';
import 'package:warden/mode.dart';

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
  Environment environment;
  Mode mode;
  List<String> environmentArguments = [];
  Logger log = createLogger();
  bool debug;

  Processor({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
    required this.warnings,
    required this.name,
    required this.environment,
    required this.mode,
    required this.debug,
  }) {
    _addVariables();
  }

  /// Executes the configured command and prints stdout and stderr
  /// with colored formatting.
  ///
  /// - Green for success output
  /// - Blue for warnings
  /// - Red for errors
  ///
  /// The method returns a [Future] that completes after the command runs.
  dynamic run() async {
    if (executable == "dart") {
      _addStoredEnvironmentVarsToArguments();
    }
    final stopwatch = Stopwatch()..start();
    final taskSpinner = Spinner(AnsiStyles.cyan(
        "✔ [task ${AnsiStyles.cyanBright.bold(name)}${AnsiStyles.cyan("] started...")}"));
    taskSpinner.start();
    var result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
    );
    taskSpinner.stop();
    stopwatch.stop();

    final taskStdOut = result.stdout.toString();
    final isDartCompileTask = executable == "dart" && arguments.contains("compile");
    final isDartCompileError = isDartCompileTask && taskStdOut.contains("Error");
    // final isDartCompileWarning = isDartCompileTask && taskStdOut.contains("Warning");

    // Print non dart compile errors - e.g `dart sass ...`
    if (result.stderr.toString().trim().isNotEmpty && !isDartCompileTask) {
      _printNoneDartCompileTaskErrors(result);
    }

    // Print non dart compile warnings
    _printNonDartCompileTaskWarnings(result);

    // Print Dart compile errors
    if (isDartCompileError) {
      _printDartCompileTaskErrors(taskStdOut);
    } else {
      // All dart tasks get printed here
      _printDartTaskSuccess(stopwatch);
    }
  }

  _addVariables() {
    if (mode.mode == "development") {
      if (debug) {
        log.info("Setting development environment variables.");
      }
      environment.devEnvVariables.forEach((k, v) {
        environmentArguments.add("-D$k=$v");
      });
    } else {
      if (debug) {
        log.info("Setting production environment variables.");
      }
      environment.prodEnvVariables.forEach((k, v) {
        environmentArguments.add("-D$k=$v");
      });
    }
  }

  _addStoredEnvironmentVarsToArguments() {
    // We want to be sure that the compile cmd is `dart compile js ...`. As the
    // features develop, we might want to revisit this / make less static.
    if (arguments.length >= 2 &&
        arguments[0] == "compile" &&
        arguments[1] == "js") {
      arguments.addAll(environmentArguments);
    }
  }

  String _printTime(Stopwatch stopwatch, String result) {
    final elapsed = stopwatch.elapsed;
    return AnsiStyles.cyan("✔ [task ${AnsiStyles.cyanBright.bold(name)}"
        "${AnsiStyles.cyan("] completed task in took ")}"
        "${AnsiStyles.white("${elapsed.inSeconds}.${elapsed.inMilliseconds % 1000}s")}");
  }


  void _printNoneDartCompileTaskErrors(dynamic result) {
      final containsError =
          result.stderr.toString().trim().toLowerCase().contains("error");
      if (containsError) {
        stderr.writeln(AnsiStyles.red("✖ [task $name] ${result.stderr}"));
        throw ProcessingCompileException();
      }
  }

  void _printNonDartCompileTaskWarnings(dynamic result) {
   final containsWarning =
          result.stderr.toString().trim().toLowerCase().contains("warning");
      final containsError =
          result.stderr.toString().trim().toLowerCase().contains("error");
      if (containsWarning && !containsError) {
        if (warnings) {
          stderr.writeln(
              AnsiStyles.yellowBright("⚠ [task $name] ${result.stderr}"));
        }
      }
  }

  void _printDartTaskSuccess(Stopwatch stopwatch) {
    print(_printTime(stopwatch, name));
  }

  void _printDartCompileTaskErrors(String taskStdOut) {
    print(AnsiStyles.red(
            "✖ [task $name] ${AnsiStyles.redBright.bold(taskStdOut)}"));
        throw ProcessingCompileException();
  }
}
