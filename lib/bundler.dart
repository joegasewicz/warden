import "dart:io";
import "package:ansicolor/ansicolor.dart";
import "package:path/path.dart" as p;
import "package:warden/cli.dart";
import "package:warden/destination.dart";



abstract class BaseBundler {

  late AnsiPen greenPen;
  late AnsiPen redPen;
  late AnsiPen bluePen;
  late StringBuffer buffer;
  late String bundlePath;
  String dependencyMainFile;
  late Directory outputDir;
  final Destination destination;

  BaseBundler(this.destination, {required this.dependencyMainFile}) {
    greenPen = AnsiPen()..green();
    redPen = AnsiPen()..red(bold: true);
    bluePen = AnsiPen()..blue();
    buffer = StringBuffer();
    outputDir = Directory(destination.destination);
    bundlePath = p.join(outputDir.path, "bundle.js");
  }

  void bundleFiles(List<String> files, String dependencySrc, StringBuffer buff);


  void start() {
    buffer.writeln("/*");
    buffer.writeln(drawLogo());
    buffer.writeln("*/");
    buffer.writeln(
        "// ---------------------  WARDEN >> START -------------------- //");
    buffer.writeln("");
  }

  void end() {
    // Bundle main JS file
    if (dependencyMainFile != "") {
      _bundleMainFile(buffer, dependencyMainFile);
    }
    buffer.writeln(
        "// ----------------------  WARDEN << END -------------------- //");
    final bundleFile = File(p.join(bundlePath));
    bundleFile.writeAsStringSync(buffer.toString());
    print(greenPen("[WARDEN]: ✅Bundled JS files into: $bundlePath"));
  }

  void _bundleMainFile(StringBuffer buffer, String dependencyMainFile) {
    final mainSrc = File(dependencyMainFile);
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

}

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
class Bundler extends BaseBundler {

  late Directory nodeModules;

  Bundler(
      super.destination, {
      required super.dependencyMainFile,
  }) {

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
  @override
  void bundleFiles(List<String> files, String dependencySrc, StringBuffer buff) {
    // Bundle all dependency files
    _bundleFiles(buff, files, dependencySrc);
  }



  void _bundleFiles(StringBuffer buffer, List<String> files, String dependencySrc) {
    final nodeModules = Directory(dependencySrc);
    for (final relativePath in files) {
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
