class Task {

  String name;
  String executable;
  List<String> args;
  String projectPath;

  Task({
    required this.name,
    required this.executable,
    required this.args,
    required this.projectPath,
  });

  @override
  String toString() {
    return "Task("
        "name: $name, "
        "executable: $executable, "
        "args: $args, "
        "projectPath: $projectPath"
        ")";
    }

}
