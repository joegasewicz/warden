import "dart:io";
import "package:path/path.dart" as p;

class AssetMover {
  AssetMover();

  void init() {
    final nodeModules = Directory("../../web/node_modules");
    final outputDir = Directory("../../web/static");

    final filesToMove = [
      'bootstrap/dist/js/bootstrap.min.js',
      'bootstrap/dist/css/bootstrap.min.css',
      'popper.js/dist/umd/popper.min.js',
    ];

    for (final relativePath in filesToMove) {
      final source = File(p.join(nodeModules.path, relativePath));
      final destination = File(p.join(outputDir.path, p.basename(relativePath)));

      if (!source.existsSync()) {
        stderr.writeln("Missing file: ${source.path}");
        continue;
      }

      destination.createSync(recursive: true);
      destination.writeAsBytesSync(source.readAsBytesSync());
      print("Moved: ${source.path} -> ${destination.path}");
    }
  }
}