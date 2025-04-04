import "dart:io";
import "package:ansicolor/ansicolor.dart";
import "package:path/path.dart" as p;
import "package:warden/conf/dependency.dart";
import "package:warden/conf/destination.dart";

/// The `AssetMover` class is responsible for copying third-party frontend assets
/// (like JavaScript or CSS files) from a `node_modules` source directory to a public
/// `static` output directory.
///
/// This is typically used when preparing assets for deployment or bundling
/// in a static website or web app. The files are defined in the `dependencies` section
/// of the Warden config (`warden.yaml`).
///
/// Any missing files will be logged to the terminal.
class AssetMover {
  final Dependency dependencies;
  final Destination destination;
  late Directory nodeModules;
  late Directory outputDir;

  AssetMover({
    required this.dependencies,
    required this.destination,
  }) {
    nodeModules = Directory(dependencies.source);
    outputDir = Directory(destination.destination);
  }

  /// Copies each file defined in `dependencies.files` from the `node_modules` directory
  /// to the configured output directory.
  ///
  /// If a file doesn't exist, Warden will print a warning in red.
  /// Successfully moved files will be logged in green.
  void moveFiles() {
    final greenPen = AnsiPen()..green();
    final redPen = AnsiPen()..red(bold: true);

    for (final relativePath in dependencies.files) {
      final source = File(p.join(nodeModules.path, relativePath));
      final destination = File(
        p.join(outputDir.path, p.basename(relativePath)),
      );

      if (!source.existsSync()) {
        stderr.writeln(redPen("[WARDEN]: Missing file: ${source.path}"));
        continue;
      }

      destination.createSync(recursive: true);
      destination.writeAsBytesSync(source.readAsBytesSync());
      print(greenPen("[WARDEN]: Moved ${source.path} -> ${destination.path}"));
    }
  }
}
