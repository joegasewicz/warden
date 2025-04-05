import 'package:ansicolor/ansicolor.dart';
import "package:path/path.dart" as p;

import 'package:warden/asset_mover.dart';
import 'package:warden/bundler.dart';
import 'package:warden/conf/conf.dart';
import 'package:warden/processor.dart';
import 'package:watcher/watcher.dart';

/// The `Warden` class orchestrates the full static build process,
/// including file watching, compiling, moving, and bundling.
///
/// It watches a source directory for changes and automatically:
/// - Runs defined `tasks` (e.g., Dart to JS compilation, Sass)
/// - Moves or bundles dependencies from `node_modules`
///
/// The behavior is defined via a `warden.yaml` config file.
/// Supports bundling JS files into a single `bundle.js` file.
///
/// Example usage:
/// ```bash
/// dart run warden --file=warden.yaml
/// ```
class Warden {
  Conf config;
  List<Processor> processors = [];

  Warden({required this.config});

  run() async {
    final greenPen = AnsiPen()..green();
    final watcher = DirectoryWatcher(config.sourceDirectory.sourceDirectory);
    final deps = AssetMover(
      dependencies: config.dependencies,
      destination: config.destination,
    );
    final bundler = Bundler(
      dependencies: config.dependencies,
      destination: config.destination,
    );

    for (var task in config.tasks) {
      final processor = Processor(
        executable: task.executable,
        arguments: task.args,
        workingDirectory: task.src,
        warnings: task.warnings,
        name: task.name,
      );

      processors.add(processor);
    }

    // Initiate initial compilations
    for (var processor in processors) {
      await processor.run();
    }
    // Moves files AFTER main JS src is built in case it's included in the bundle file.
    if (config.dependencies.bundle) {
      bundler.bundleFiles();
    } else {
      deps.moveFiles();
    }

    watcher.events.listen((event) async {
      final normalized = p.normalize(event.path);
      // Recompile
      for (var processor in processors) {
        if (!normalized.contains(config.destination.destination)) {
          print(greenPen(
              "[WARDEN]: 🔍Changes detected in ${event.path}. Recompiling"));
          await processor.run();
        }
      }
    });
  }
}
