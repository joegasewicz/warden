import "dart:io";
import "package:ansi_styles/ansi_styles.dart";
import "package:path/path.dart" as p;
import "package:warden/assets.dart";
import "package:warden/destination.dart";

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
  final Destination destination;
  final Asset assets;
  late Directory nodeModules;
  late Directory outputDir;

  AssetMover({
    required this.destination,
    required this.assets,
  }) {
    outputDir = Directory(destination.destination);
  }

  /// Copies each file defined in `dependencies.files` from the `node_modules` directory
  /// to the configured output directory.
  ///
  /// If a file doesn't exist, Warden will print a warning in red.
  /// Successfully moved files will be logged in green.
  void moveAllFiles(List<String> files, String dependencySrc) {
    _move(files, dependencySrc);
  }

  void moveFilesExclSuffix(
      String suffix, List<String> files, String dependencySrc) {
    List<String> nonJSFiles = [];
    for (String file in files) {
      if (file.endsWith(suffix)) {
        continue;
      }
      nonJSFiles.add(file);
    }
    _move(nonJSFiles, dependencySrc);
  }

  void moveAssets() {
    for (final dirName in assets.directories) {
      final sourceDir = Directory(p.join(assets.source, dirName));
      final destDir = Directory(p.join(outputDir.path, dirName));

      if (!sourceDir.existsSync()) {
        stderr.writeln(
            AnsiStyles.red("⚠ missing asset directory [${sourceDir.path}]"));
        continue;
      }
      for (final entity in sourceDir.listSync(recursive: true)) {
        if (entity is File) {
          final relative = p.relative(entity.path, from: sourceDir.path);
          final targetFile = File(p.join(destDir.path, relative));
          targetFile.createSync(recursive: true);
          targetFile.writeAsBytesSync(entity.readAsBytesSync());
          print(
              "${AnsiStyles.cyan("✔ copied asset: ")}${AnsiStyles.magenta("[${entity.path} -> ${targetFile.path}]")}");
        }
      }
    }
  }

  void _move(List<String> files, String dependencySrc) {
    for (final relativePath in files) {
      final source = File(p.join(Directory(dependencySrc).path, relativePath));
      final destination = File(
        p.join(outputDir.path, p.basename(relativePath)),
      );

      if (!source.existsSync()) {
        stderr.writeln(AnsiStyles.red("✖ missing file: [${source.path}]"));
        continue;
      }

      destination.createSync(recursive: true);
      destination.writeAsBytesSync(source.readAsBytesSync());
      print(
          AnsiStyles.green("✔ moved [${source.path} -> ${destination.path}]"));
    }
  }
}
