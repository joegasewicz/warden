class Task {
  String name;
  String executable;
  List<String> args;
  String src;

  Task({
    required this.name,
    required this.executable,
    required this.args,
    required this.src,
  });

  @override
  String toString() {
    return "Task("
        "name: $name, "
        "executable: $executable, "
        "args: $args, "
        "src: $src"
        ")";
  }
}
