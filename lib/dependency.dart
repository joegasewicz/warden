import 'package:warden/asset_mover.dart';
import 'package:warden/bundler.dart';

class Dependency {
  String source;
  bool bundle;
  List<String> files;
  AssetMover assetMover;
  Bundler bundler;

  Dependency({
    required this.source,
    required this.bundle,
    required this.files,
    required this.assetMover,
    required this.bundler,
  });

  void moveAllFiles() {
    assetMover.moveAllFiles(files, source);
  }

  void moveFilesExclSuffix() {
    assetMover.moveFilesExclSuffix(".js", files, source);
  }

  void moveAssets() {
    assetMover.moveAssets();
  }

  void bundleFiles(StringBuffer buffer) {
    bundler.bundleFiles(files, source, buffer);
  }

  @override
  String toString() {
    return "Dependency("
        "source: $source, "
        "bundle: $bundle, "
        "files: $files"
        ")";
  }

}
