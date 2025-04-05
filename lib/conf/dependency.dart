class Dependency {
  String source;
  bool bundle;
  String main;
  List<String> files;

  Dependency(
      {required this.source,
      required this.bundle,
      required this.main,
      required this.files});

  @override
  String toString() {
    return "Dependency("
        "source: $source, "
        "bundle: $bundle, "
        "main: $main, "
        "files: $files"
        ")";
  }
}
