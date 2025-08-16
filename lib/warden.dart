import "package:ansi_styles/ansi_styles.dart";
import "package:logging/logging.dart";
import "package:path/path.dart" as p;
import "package:warden/environment.dart";
import "package:warden/exceptions.dart";
import "package:warden/excluder.dart";
import "package:warden/logger.dart";
import "package:warden/main_file.dart";
import "package:warden/mode.dart";
import 'dart:io';
import "package:yaml/yaml.dart";

import "package:warden/assets.dart";
import "package:warden/destination.dart";
import "package:warden/source_directory.dart";
import "package:warden/task.dart";
import "package:warden/dependency.dart";
import 'package:warden/asset_mover.dart';
import 'package:warden/bundler.dart';
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
  List<Processor> processors = [];
  final String wardenFilePath;
  final bool debug;
  late Excluder excluder;
  late SourceDirectory sourceDirectory;
  late Mode mode;
  late Destination destination;
  late List<Dependency> dependencies = [];
  late Environment environment;
  late List<Task> tasks = [];
  late Asset assets;
  late BaseBundler bundler;
  late MainFile mainFile;
  Logger log = createLogger();

  Warden({
    required this.wardenFilePath,
    required this.debug,
  }) {
    File wardenFile = File(wardenFilePath);
    String fileContent = wardenFile.readAsStringSync();
    dynamic yamlMap = loadYaml(fileContent);
    _setSourceDirectory(yamlMap);
    _setMode(yamlMap);
    _setMainFile(yamlMap);
    _setDestination(yamlMap);
    _setAssets(yamlMap);
    _setDependencies(yamlMap);
    _setTasks(yamlMap);
    _setEnvironment(yamlMap);

    if (debug) {
      log.info("🐛Debug mode");
    }

    bundler =
        Bundler(destination, dependencyMainFile: mainFile.src, debug: debug);
    final List<String> ignoredExtensions = [".tmp", ".DS_Store"];
    final List<String> ignoredDirs = [destination.destination];

    excluder = Excluder(
      ignoredExtensions: ignoredExtensions,
      ignoredDirs: ignoredDirs,
      debug: debug,
    );
  }

  watch() async {
    try {
      await _runInitialBuild();
    } on ProcessingCompileException catch (e) {
      if (debug) {
        log.info(e.toString());
      }
    }

    final watcher = DirectoryWatcher(sourceDirectory.sourceDirectory);
    _runWatcher(watcher);
  }

  build() async {
    try {
      await _runInitialBuild();
    } on ProcessingCompileException catch (e) {
      if (debug) {
        log.info(e.toString());
      }
    }
  }

  _runInitialBuild() async {
    final stopwatch = Stopwatch()..start();
    for (var task in tasks) {
      final processor = Processor(
        executable: task.executable,
        arguments: task.args,
        workingDirectory: task.src,
        warnings: task.warnings,
        name: task.name,
        environment: environment,
        mode: mode,
        debug: debug,
      );

      processors.add(processor);
    }

    // Initiate initial compilations
    for (var processor in processors) {
      await processor.run();
    }
    // pre bundle the initial run
    _bundleAndMoveFiles(stopwatch);
  }

  _runWatcher(Watcher watcher) {
    watcher.events.listen((event) async {
      final normalized = p.normalize(event.path);
      // Ignore files
      if (excluder.containsIgnoredFileExt(event.path)) {
        return;
      }
      if (excluder.containsExcludedDirs(event.path)) {
        return;
      }
      final stopwatch = Stopwatch()..start();
      final futures = <Future>[];
      // Recompile

      try {
        for (var processor in processors) {
          if (!normalized.contains(destination.destination)) {
            print(AnsiStyles.cyanBright(
                "➜ changes detected in ${AnsiStyles.magentaBright.bold("[${event.path}]")} "
                "${AnsiStyles.cyanBright.bold("➤ recompiling")}"));
            futures.add(processor.run());
          }
        }
        // Wait for all processes to run & then re bundle file
        await Future.wait(futures);
        _bundleAndMoveFiles(stopwatch);
      } on ProcessingCompileException catch (e) {
        if (debug) {
          log.info(e.toString());
        }
      }
    });
  }

  run() async {
    final stopwatch = Stopwatch()..start();
    final watcher = DirectoryWatcher(sourceDirectory.sourceDirectory);
    for (var task in tasks) {
      final processor = Processor(
        executable: task.executable,
        arguments: task.args,
        workingDirectory: task.src,
        warnings: task.warnings,
        name: task.name,
        environment: environment,
        mode: mode,
        debug: debug,
      );

      processors.add(processor);
    }

    // Initiate initial compilations
    for (var processor in processors) {
      await processor.run();
    }
    // pre bundle the initial run
    _bundleAndMoveFiles(stopwatch);

    watcher.events.listen((event) async {
      final normalized = p.normalize(event.path);
      final futures = <Future>[];
      // Recompile
      for (var processor in processors) {
        if (!normalized.contains(destination.destination)) {
          print(AnsiStyles.green(
              "🔍Changes detected in ${event.path}. Recompiling"));
          futures.add(processor.run());
        }
      }
      // Wait for all processes to run & then re bundle file
      await Future.wait(futures);
      _bundleAndMoveFiles(stopwatch);
    });
  }

  void _bundleAndMoveFiles(Stopwatch stopwatch) {
    bundler.destroyBundleFile();
    // Initiate the String buffer
    bundler.start();
    // Moves files AFTER main JS src is built in case it's included in the bundle file.
    for (var dependency in dependencies) {
      if (dependency.bundle) {
        // pass the bundler buffer to the dependency owned buffer
        dependency.bundleFiles(bundler.buffer);
        dependency.moveFilesExclSuffix();
      } else {
        dependency.moveAllFiles();
      }
      if (assets.source != "") {
        dependency.moveAssets();
      }
    }
    // Bundle the main file
    bundler.end(stopwatch);
  }

  void _setSourceDirectory(dynamic yamlMap) {
    sourceDirectory = SourceDirectory(
      sourceDirectory: yamlMap["source_dir"] as String,
    );
  }

  void _setMode(dynamic yamlMap) {
    mode = Mode(mode: yamlMap["mode"] as String?);
  }

  void _setMainFile(dynamic yamlMap) {
    mainFile = MainFile(
      src: yamlMap["main_file"] as String,
    );
  }

  void _setDestination(dynamic yamlMap) {
    destination = Destination(destination: yamlMap["destination"] as String);
  }

  void _setDependencies(dynamic yamlMap) {
    final dependencyData = yamlMap["dependencies"];
    for (var dependency in dependencyData) {
      if (dependency is YamlMap) {
        _setDependency(Map<String, dynamic>.from(dependency));
      }
    }
  }

  void _setEnvironment(dynamic yamlMap) {
    final environmentData = yamlMap["environment"];
    Map<String, String> devEnvVariables = {};
    Map<String, String> prodEnvVariables = {};

    if (environmentData != null) {
      final devMap = environmentData["dev"] as Map?;
      final prodMap = environmentData["prod"] as Map?;
      if (devMap != null) {
        devEnvVariables.addAll(Map<String, String>.from(devMap));
      }
      if (prodMap != null) {
        prodEnvVariables.addAll(Map<String, String>.from(prodMap));
      }
    }
    environment = Environment(
      devEnvVariables: devEnvVariables,
      prodEnvVariables: prodEnvVariables,
    );
  }

  void _setDependency(Map<String, dynamic> dependency) {
    var bundle = false;
    var mainFile = "";

    if (dependency["bundle"] != null) {
      bundle = dependency["bundle"] as bool;
    }
    if (dependency["main"] != null) {
      mainFile = dependency["main"] as String;
    }
    dependencies.add(Dependency(
      source: dependency["source"] as String,
      bundle: bundle,
      files: List<String>.from(dependency["files"]),
      assetMover: AssetMover(destination: destination, assets: assets),
      bundler: Bundler(destination, dependencyMainFile: mainFile, debug: debug),
    ));
  }

  void _setTasks(dynamic yamlMap) {
    yamlMap['tasks'].forEach((key, value) {
      var warnings = true;
      if (value["warnings"] != null) {
        warnings = value["warnings"] as bool;
      }

      Task task = Task(
        name: key,
        executable: value["executable"] as String,
        args: List<String>.from(value["args"]),
        src: value["src"] as String,
        warnings: warnings,
      );
      tasks.add(task);
    });
  }

  _setAssets(dynamic yamlMap) {
    var assetResult = yamlMap["assets"];
    String source = "";
    List<String> directories = [];
    if (assetResult != null && assetResult["source"] != null) {
      source = assetResult["source"];
    }
    if (assetResult != null && assetResult["directories"] != null) {
      directories = List<String>.from(assetResult["directories"]);
    }
    assets = Asset(
      source: source,
      directories: directories,
    );
  }
}
