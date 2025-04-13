import 'package:ansicolor/ansicolor.dart';
import "package:path/path.dart" as p;
import "package:warden/main_file.dart";
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
  late SourceDirectory sourceDirectory;
  late Destination destination;
  late List<Dependency> dependencies = [];
  late List<Task> tasks = [];
  late Asset assets;
  late BaseBundler bundler;
  late MainFile mainFile;

  Warden({required this.wardenFilePath}) {
    File wardenFile = File(wardenFilePath);
    String fileContent = wardenFile.readAsStringSync();
    dynamic yamlMap = loadYaml(fileContent);
    _setSourceDirectory(yamlMap);
    _setMainFile(yamlMap);
    _setDestination(yamlMap);
    _setAssets(yamlMap);
    _setDependencies(yamlMap);
    _setTasks(yamlMap);
    // bundler = Bundler(destination.destination, dependencyMainFile: mainFile.src);
    bundler = Bundler(destination, dependencyMainFile: mainFile.src);
  }

  run() async {
    final greenPen = AnsiPen()..green();
    final watcher = DirectoryWatcher(sourceDirectory.sourceDirectory);
    for (var task in tasks) {
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
    bundler.end();

    watcher.events.listen((event) async {
      final normalized = p.normalize(event.path);
      // Recompile
      for (var processor in processors) {
        if (!normalized.contains(destination.destination)) {
          print(greenPen(
              "[WARDEN]: 🔍Changes detected in ${event.path}. Recompiling"));
          await processor.run();
        }
      }
    });
  }

  void _setSourceDirectory(dynamic yamlMap) {
    sourceDirectory = SourceDirectory(
      sourceDirectory: yamlMap["source_dir"] as String,
    );
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
    final _dependencies = yamlMap["dependencies"];
    for (var dependency in _dependencies) {
      if (dependency is YamlMap) {
        _setDependency(Map<String, dynamic>.from(dependency));
      }
    }
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
      bundler: Bundler(destination, dependencyMainFile: mainFile),
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
