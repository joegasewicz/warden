class Asset {

  String source;
  List<String> directories;

  Asset({
    required this.source,
    required this.directories,
  });

  @override
  String toString() {
    return "Asset(source: $source, directories: $directories)";
  }
}