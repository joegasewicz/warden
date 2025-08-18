import 'dart:io';

import 'package:logging/logging.dart';
import 'package:warden/logger.dart';

class Excluder {
  List<String> ignoredExtensions;
  List<String> ignoredDirs;
  bool debug;
  Logger log = createLogger();

  Excluder({
    required this.ignoredExtensions,
    required this.ignoredDirs,
    required this.debug,
  }) {
    // Remove all end slashes from dir paths
    for (var i = 0; i < ignoredDirs.length; i++) {
      if (ignoredDirs[i].endsWith(Platform.pathSeparator)) {
        ignoredDirs[i] = ignoredDirs[i].substring(0, ignoredDirs[i].length - 1);
      }
    }
  }

  containsIgnoredFileExt(String path) {
    bool ignoredExtension = false;
    for (final ext in ignoredExtensions) {
      if (path.endsWith(ext)) {
        if (debug) {
          log.info("ignored file - $path with extension - $ext");
        }
        ignoredExtension = true;
        break;
      }
    }
    return ignoredExtension;
  }

  containsExcludedDirs(String path) {
    bool ignoredDir = false;
    for (final dir in ignoredDirs) {
      if (path.contains(dir)) {
        if (debug) {
          log.info("ignored directory - $dir for path: $path");
        }
        ignoredDir = true;
        break;
      }
    }
    return ignoredDir;
  }
}
