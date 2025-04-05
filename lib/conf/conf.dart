import 'dart:io';
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

  Conf({required this.wardenFilePath}) {
    File wardenFile = File(wardenFilePath);
    String fileContent = wardenFile.readAsStringSync();
    dynamic yamlMap = loadYaml(fileContent);
    setSourceDirectory(yamlMap);
    setDestination(yamlMap);
    setDependencies(yamlMap);
    setTasks(yamlMap);
  }

  void setSourceDirectory(dynamic yamlMap) {
    sourceDirectory = SourceDirectory(
      sourceDirectory: yamlMap["source_dir"] as String,
    );
  }

  void setDestination(dynamic yamlMap) {
    destination = Destination(destination: yamlMap["destination"] as String);
  }

  void setDependencies(dynamic yamlMap) {
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

  void setTasks(dynamic yamlMap) {
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
}
