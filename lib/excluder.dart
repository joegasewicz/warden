

import 'dart:io';

class Excluder {

  List<String> ignoredExtensions;
  List<String> ignoredDirs;
  bool debug;

  Excluder({
    required this.ignoredExtensions,
    required this.ignoredDirs,
    required this.debug,
  });

  containsIgnoredFileExt(File file) {
    bool ignoredExtension = false;
    for (final ext in ignoredExtensions) {
      if (file.path.endsWith(ext)) {
        ignoredExtension = true;
        break;
      }
    }
    return ignoredExtension;
  }

  excludeDirs(File file) {
    bool ignoredDir = false;
    for (final dir in ignoredDirs) {
      final dirPattern = "${Platform.pathSeparator}$dir${Platform.pathSeparator}";
      if(file.path.contains(dirPattern)) {
        ignoredDir = true;
        break;
      }
    }
    return ignoredDir;
  }

}