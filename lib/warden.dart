import 'dart:io';
import "package:path/path.dart" as p;

import 'package:warden/asset_mover.dart' as warden;
import 'package:warden/processor.dart';
import 'package:watcher/watcher.dart';

class Warden {

  run() async {
    final watcher = DirectoryWatcher("../../web/public");

    final deps = new warden.AssetMover();
    // Dart processor
    final dartExc = "dart";
    final sassExc = "dart";
    final dartArgs = [
      "compile",
      "js",
      "main.dart",
      "-o",
      "../../static/main.js"
    ];
    final sassArgs = [
      "run",
      "sass",
      "index.scss:../../static/index.css",
    ];
    final dartWorkingDirectory = "../../web/public/web";
    final sassWorkingDirectory = "../../web/public/sass";
    // Sass processor

    final dartProcessor = new Processor(dartExc, dartArgs, dartWorkingDirectory);
    final sassProcessor = new Processor(sassExc, sassArgs, sassWorkingDirectory);

    // Initiate initial compilations
    deps.init();
    await dartProcessor.run();
    await sassProcessor.run();

    watcher.events.listen((event) async {
      final normalized = p.normalize(event.path);
      // Recompile
      if (!normalized.contains("/web/static/")) {
        print("Changes deteced in ${event.path}. Recompiling");
        await dartProcessor.run();
      }
      if (!normalized.contains("/web/static/")) {
        print("Changes detected in ${event.path}. Recompiling...");
        await sassProcessor.run();
      }
    });


  }
}