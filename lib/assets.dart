class Asset {
  String source;
  List<String> directories;
  /// { quality: 0-100, use: true/false }
  Map<String, dynamic> compress;

  Asset({
    required this.source,
    required this.directories,
    required this.compress,
  });

  @override
  String toString() {
    return "Asset("
        "source: $source, "
        "directories: $directories, "
        "compress: $compress"
        ")";
  }
}
