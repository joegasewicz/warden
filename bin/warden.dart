import 'package:args/args.dart';
import 'package:warden/cli.dart';
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
    ..addFlag("version", abbr: "v", help: "Get the latest Warden version.")
    ..addFlag("build", abbr: "b", help: "Build command.")
    ..addFlag("watch", abbr: "w", help: "Build & watch for file changes.");


  // Handle args
  final argResults = parser.parse(arguments);

  // Handle version
  if (argResults["version"]) {
    print("v0.6.1");
    return;
  }



  String wardenFile = "warden.yaml";
  if (argResults.wasParsed("file")) {
    wardenFile = argResults["file"];
  }

  // Create a new instance of Warden
  final warden = Warden(wardenFilePath: wardenFile);

  if (argResults["watch"] != null) {
    printLogo(true);
    warden.watch();
    return;
  }

  if (argResults["build"] != null) {
    printLogo(false);
    warden.build();
    return;
  }

  // Print out usage if no flags are set
  print(parser.usage);

}
