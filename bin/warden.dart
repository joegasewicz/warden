import 'package:args/args.dart';
import 'package:warden/cli.dart';
import 'package:warden/conf/conf.dart';
import 'package:warden/warden.dart';

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
    ..addFlag("version", abbr: "v", help: "Get the latest Warden version.");

  // Handle args
  final argResults = parser.parse(arguments);

  // Handle version
  if (argResults["version"]) {
    print("v0.3.0");
    return;
  }

  printLogo();

  String wardenFile = "warden.yaml";
  if (argResults.wasParsed("file")) {
    wardenFile = argResults["file"];
  }

  final conf = Conf(wardenFilePath: wardenFile);

  final warden = Warden(config: conf);
  warden.run();
}
