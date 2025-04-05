class Task {
  String name;
  String executable;
  List<String> args;
  String src;
  bool warnings;

  Task({
    required this.name,
    required this.executable,
    required this.args,
    required this.src,
    required this.warnings,
  });

  @override
  String toString() {
    return "Task("
        "name: $name, "
        "executable: $executable, "
        "args: $args, "
        "src: $src, "
        "warnings: $warnings"
        ")";
  }
}
