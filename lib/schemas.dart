class ConfigSchema {
  final String sourceDir;
  final String mode;
  final String destination;
  final String mainFile;
  final bool debug;
  final DependencySchema denpendencies;
  final AssetSchema assets;
  final List<TaskSchema> tasks;
  final EnvironmentSchema environments;

  ConfigSchema({
    required this.sourceDir,
    required this.mode,
    required this.destination,
    required this.mainFile,
    required this.debug,
    required this.denpendencies,
    required this.assets,
    required this.tasks,
    required this.environments,
  });

  factory ConfigSchema.fromMap(Map<String, dynamic> m) {
    return ConfigSchema(
        sourceDir: getStr(m["sourceDir"], "src"),
        mode: getStr(m["mode"], ""),
        destination: getStr("destination", "static"),
        mainFile: getStr(m["mainFile"], "main.js"),
        debug: m["debug"] ?? true,
        denpendencies: DependencySchema.fromMap(m["dependencies"] as Map? ?? const {}),
        assets: AssetSchema.fromMap(m["assets"] as Map? ?? const {}),
        tasks: getTaskList(m),
        environments: getEnvironmentMap(m),
    );
  }

  static String getStr(Object? value, String fallback) {
   if (value is String && value.isNotEmpty) {
      return value;
   }
   return fallback;
  }

  static List<String> getStrList(Object strList) {
    if (strList is List<String>) {
      return strList;
    }
    return [];
  }

  static List<TaskSchema> getTaskList(Map m) {
    List<TaskSchema> tasks = [];
    final tasksList = m["tasks"];
    if (tasksList is! List) {
      return tasks;
    }
    for (final taskOuter in tasksList) {
      if (taskOuter is! Map) {
        return tasks;
      }
      final taskName = taskOuter.keys.first;
      final taskInner = taskOuter[taskName];
      tasks.add(TaskSchema.fromMap(taskInner, taskName));
    }
    return tasks;
  }

  static EnvironmentSchema getEnvironmentMap(Map m) {
    return const {} as EnvironmentSchema;
  }
}

class DependencySchema {

  final String source;
  final bool bundle;
  final List<String> files;

  DependencySchema({
    required this.source,
    required this.bundle,
    required this.files,
  });

  factory DependencySchema.fromMap(Map m) {
    return DependencySchema(
      source: ConfigSchema.getStr(m["source"], "source"),
      bundle: m["bundle"] is bool ? m["bundle"] : true,
      files: ConfigSchema.getStrList(m["files"]),
    );
  }
}

class AssetSchema {

  final String source;
  final List<String> directories;
  final CompressSchema? compress;

  AssetSchema({
    required this.source,
    required this.directories,
    required this.compress,
  });

  factory AssetSchema.fromMap(Map m) {
    return AssetSchema(
      source: ConfigSchema.getStr(m["source"], ""),
      directories: ConfigSchema.getStrList(m["directories"]),
      compress: CompressSchema.fromMap(m["compress"] as Map? ?? const {}),
    );
  }
}

class CompressSchema {
  final int quality;

  CompressSchema({ required this.quality });

  factory CompressSchema.fromMap(Map m) {
    return CompressSchema(quality: m["quality"] ? m["quality"] : 100);
  }
}

class TaskSchema {

  final String name;
  final String executable;
  final List<String> args;
  final String src;
  final bool warnings;

  TaskSchema({
    required this.name,
    required this.executable,
    required this.args,
    required this.src,
    required this.warnings,
  });

  factory TaskSchema.fromMap(Map m, String name) {
    return TaskSchema(
      name: ConfigSchema.getStr(name, ""),
      executable: ConfigSchema.getStr(m["executable"], ""),
      args: ConfigSchema.getStrList(m["args"]),
      src: ConfigSchema.getStr(m["src"], ""),
      warnings: m["warnings"] ? m["warnings"] : false,
    );
  }
}

class EnvironmentSchema {
  final List<Map<String, String>> devVariables;
  final List<Map<String, String>> prodVariables;

  EnvironmentSchema({
    required this.devVariables,
    required this.prodVariables,
  });

  factory EnvironmentSchema.fromMap(
      List<Map<String, String>> devVariables,
      List<Map<String, String>> prodVariables
  ) {
    return EnvironmentSchema(
      devVariables: devVariables,
      prodVariables: prodVariables,
    );
  }
}
