import "package:path/path.dart" as p;

import 'package:warden/asset_mover.dart' as warden;
import 'package:warden/conf/conf.dart';
import 'package:warden/processor.dart';
import 'package:watcher/watcher.dart';

class Warden {
  Conf config;
  List<Processor> processors = [];

  Warden({required this.config});

  run() async {
    final watcher = DirectoryWatcher(config.sourceDirectory.sourceDirectory);

    final deps = warden.AssetMover(
      dependencies: config.dependencies,
      destination: config.destination,
    );
    // Sass processor
    for (var task in config.tasks) {
      final processor = Processor(
        executable: task.executable,
        arguments: task.args,
        workingDirectory: task.src,
      );

      processors.add(processor);
    }

    // Initiate initial compilations
    deps.init();
    for (var processor in processors) {
      await processor.run();
    }

    watcher.events.listen((event) async {
      final normalized = p.normalize(event.path);
      // Recompile
      for (var processor in processors) {
        if (!normalized.contains(config.destination.destination)) {
          print("Changes detected in ${event.path}. Recompiling");
          await processor.run();
        }
      }
    });
  }
}
