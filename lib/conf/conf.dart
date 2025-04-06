import 'dart:io';
import "package:warden/conf/assets.dart";
import "package:warden/conf/destination.dart";
import "package:warden/conf/source_directory.dart";
import "package:yaml/yaml.dart";

import "package:warden/conf/task.dart";
import "package:warden/conf/dependency.dart";

class Conf {
  final String wardenFilePath;
  late SourceDirectory sourceDirectory;
  late Destination destination;
  late Dependency dependencies;
  late List<Task> tasks = [];
  late Asset assets;

  Conf({required this.wardenFilePath}) {
    File wardenFile = File(wardenFilePath);
    String fileContent = wardenFile.readAsStringSync();
    dynamic yamlMap = loadYaml(fileContent);
    _setSourceDirectory(yamlMap);
    _setDestination(yamlMap);
    _setDependencies(yamlMap);
    _setAssets(yamlMap);
    _setTasks(yamlMap);
  }

  void _setSourceDirectory(dynamic yamlMap) {
    sourceDirectory = SourceDirectory(
      sourceDirectory: yamlMap["source_dir"] as String,
    );
  }

  void _setDestination(dynamic yamlMap) {
    destination = Destination(destination: yamlMap["destination"] as String);
  }

  void _setDependencies(dynamic yamlMap) {
    final root = yamlMap["dependencies"];
    var bundle = false;
    var mainFile = "";

    if (root["bundle"] != null) {
      bundle = root["bundle"] as bool;
    }
    if (root["main"] != null) {
      mainFile = root["main"] as String;
    }
    dependencies = Dependency(
      source: root["source"] as String,
      bundle: bundle,
      main: mainFile,
      files: List<String>.from(root["files"]),
    );
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
