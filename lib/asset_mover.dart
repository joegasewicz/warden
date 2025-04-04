import "dart:io";
import "package:path/path.dart" as p;
import "package:warden/conf/dependency.dart";
import "package:warden/conf/destination.dart";

class AssetMover {
  final Dependency dependencies;
  final Destination destination;

  AssetMover({
    required this.dependencies,
    required this.destination,
  });

  void init() {
    final nodeModules = Directory(dependencies.source);
    final outputDir = Directory(destination.destination);

    for (final relativePath in dependencies.files) {
      final source = File(p.join(nodeModules.path, relativePath));
      final destination = File(
        p.join(outputDir.path, p.basename(relativePath)),
      );

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
