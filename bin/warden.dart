import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:args/args.dart';
import 'package:warden/cli.dart';
import 'package:warden/warden.dart';


Future<Map<String, dynamic>> _loadDartConfig(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln("Config Dart file not found: $path");
    exitCode = 2;
    return {};
  }

  final rp = ReceivePort();
  final uri = file.absolute.uri;

  final isolate = await Isolate.spawnUri(uri, const [], rp.sendPort);
  final msg = await rp.first;
  rp.close();
  isolate.kill(priority: Isolate.immediate);

  return (msg as Map).cast<String, dynamic>();
}

/// Entry point for the Warden CLI.
///
/// This function:
/// - Prints the ASCII logo
/// - Parses command-line arguments
/// - Loads the configuration from the specified or default `warden.yaml`
/// - Instantiates and starts the [Warden] build system
///
/// ### CLI Options:
/// - `-f`, `--file`: Path to the `warden.yaml` config file. Default is `warden.yaml` in the current directory.
///
/// Example usage:
/// ```bash
/// dart run warden --file=example/warden.yaml
/// ```
void main(List<String> arguments) async {

  final parser = ArgParser()
    ..addOption("file", abbr: "f", help: "The warden yaml file.")
    ..addFlag("version", abbr: "v", help: "Get the latest Warden version.")
    ..addFlag("build", abbr: "b", help: "Build command.")
    ..addFlag("watch", abbr: "w", help: "Build & watch for file changes.")
    ..addFlag("debug", abbr: "d", help: "Debug mode.");

  // Handle args
  final argResults = parser.parse(arguments);

  // Handle version
  if (argResults["version"]) {
    print("v0.7.0");
    return;
  }

  final wardenRedFile = argResults.wasParsed("file") ? argResults["file"] : "warden.yaml";
  Map<String, dynamic>? configMap;
  if (wardenRedFile.toString().endsWith(".dart")) { // TODO .endsWth(".dart")
    configMap = await _loadDartConfig(wardenRedFile);
  }

  print("here--------> $configMap");

  String wardenFile = "warden.yaml";
  if (argResults.wasParsed("file")) {
    wardenFile = argResults["file"];
  }

  printLogo();

  // Create a new instance of Warden
  if (argResults["watch"] == true) {
    print(AnsiStyles.cyanBright.bold("👀 watching..."));
    final warden = Warden(
        config: configMap!,
        wardenFilePath: wardenFile,
        debug: argResults["debug"],
    );
    warden.watch();
    return;
  }

  if (argResults["build"] == true) {
    print(AnsiStyles.cyanBright.bold("🛠️  building..."));
    final warden = Warden(
        config: configMap!,
        wardenFilePath: wardenFile,
        debug: argResults["debug"],
    );
    warden.build();
    return;
  }

  // Print out usage if no flags are set
  print(AnsiStyles.cyan(parser.usage));
}
