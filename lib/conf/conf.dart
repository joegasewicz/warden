import 'dart:io';
import "package:warden/conf/destination.dart";
import "package:yaml/yaml.dart";

import "package:warden/conf/task.dart";
import "package:warden/conf/dependency.dart";

class Conf {

  late final String wardenFilePath;
  late List<Task> tasks = [];
  late Destination destination;
  late List<Dependency> dependencies;

  Conf(String wardenFilePath) {

    File wardenFile = File(wardenFilePath);
    String fileContent = wardenFile.readAsStringSync();
    dynamic yamlMap = loadYaml(fileContent);
    setDestination(yamlMap);
    setTasks(yamlMap);
  }

  void setTasks(dynamic yamlMap) {
   yamlMap['tasks'].forEach((key, value) {
      Task task = Task(
          name: key,
          executable: value["executable"] as String,
          args: List<String>.from(value["args"]),
          projectPath: value["project_path"] as String,
      );
      tasks.add(task);
    });
  }

  void setDestination(dynamic yamlMap) {

  }
}