class Dependency {

  String source;
  List<String> files;

  Dependency({
    required this.source,
    required this.files,
  });

  @override
  String toString() {
    return "Dependency(source: $source, files: $files)";
  }

}