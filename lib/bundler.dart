import "dart:io";
import "package:ansicolor/ansicolor.dart";
import "package:path/path.dart" as p;
import "package:warden/cli.dart";
import "package:warden/conf/dependency.dart";
import "package:warden/conf/destination.dart";

/// The `Bundler` class is responsible for managing and bundling JavaScript assets.
///
/// It combines multiple JS files (from third-party packages and optionally a custom main JS file)
/// into a single `bundle.js` output file. This is useful for reducing HTTP requests and
/// organizing frontend assets for production.
///
/// The bundler will:
/// - Read JS files listed in the `files` section of the `dependencies` block
/// - Optionally include a `main` JS file
/// - Output a single bundled `bundle.js` into the `destination` directory
/// - Log errors for any missing files
class Bundler {
  final Dependency dependencies;
  final Destination destination;
  late Directory nodeModules;
  late Directory outputDir;
  late AnsiPen greenPen;
  late AnsiPen redPen;
  late AnsiPen bluePen;

  Bundler({
    required this.dependencies,
    required this.destination,
  }) {
    nodeModules = Directory(dependencies.source);
    outputDir = Directory(destination.destination);
    greenPen = AnsiPen()..green();
    redPen = AnsiPen()..red(bold: true);
    bluePen = AnsiPen()..blue();
  }

  /// Merges and writes JavaScript files into a single `bundle.js` file.
  ///
  /// This method first adds a Warden ASCII logo and a header, then appends the contents of each
  /// third-party file listed in `dependencies.files`. If a `main` file is set, it’s appended last.
  /// After bundling, the resulting JS file is saved to the output directory.
  ///
  /// A terminal success message is printed. Missing files are logged as warnings.
  void bundleFiles() {
    final buffer = StringBuffer();
    final bundlePath = p.join(outputDir.path, "bundle.js");
    buffer.writeln("/*");
    buffer.writeln(drawLogo());
    buffer.writeln("*/");
    buffer.writeln(
        "// ---------------------  WARDEN >> START -------------------- //");
    buffer.writeln("");
    // Bundle all dependency files
    _bundleFiles(buffer);
    // Bundle main JS file
    if (dependencies.main != "") {
      _bundleMainFile(buffer);
    }
    buffer.writeln(
        "// ----------------------  WARDEN << END -------------------- //");
    final bundleFile = File(p.join(bundlePath));
    bundleFile.writeAsStringSync(buffer.toString());
    print(greenPen("[WARDEN]: ✅Bundled JS files into: $bundlePath"));
  }

  void _bundleMainFile(StringBuffer buffer) {
    final mainSrc = File(dependencies.main);
    if (!mainSrc.existsSync()) {
      stderr.writeln(
          redPen("[Warden]: ⛔️Missing file for bundling: ${mainSrc.path}"));
    } else {
      buffer.writeln(
          "// ---------------------------------------------------- //");
      buffer.writeln(
          "// ----------------- ${p.basename(mainSrc.path)} ------------------ //");
      buffer.writeln(
          "// -----------------------------------------------------//");
      final mainContent = mainSrc.readAsStringSync();
      buffer.writeln(mainContent);
      // Delete `main` file
      mainSrc.delete();
    }
  }

  void _bundleFiles(StringBuffer buffer) {
    for (final relativePath in dependencies.files) {
      final source = File(p.join(nodeModules.path, relativePath));

      if (!source.existsSync()) {
        stderr.writeln(
            redPen("[WARDEN]: ⛔️Missing file for bundling: ${source.path}"));
        continue;
      }
      // Make sure only JS files are included in the bundle
      if (!source.path.endsWith(".js")) {
        print(bluePen(
            "[WARDEN]: ⚠️Skipping bundling for none .js file - ${source.path}"));
        continue;
      }
      buffer.writeln(
          "// ---------------------------------------------------- //");
      buffer.writeln(
          "// ----------------- ${p.basename(relativePath)} ------------------ //");
      buffer.writeln(
          "// ---------------------------------------------------- //");
      final content = source.readAsStringSync();
      buffer.writeln(content);
      buffer.writeln("");
    }
  }
}
