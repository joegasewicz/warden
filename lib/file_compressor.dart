import 'dart:ffi';
import 'dart:io';
import 'package:image/image.dart' as img;

class FileCompressor {

  List<String> fileTypes = [
    "jpg",
    "png",
    "jpeg",
    "gif",
    "bmp",
    "tga",
    "webp",
    "tiff",
  ];

  Future<void> compress(String fileName, Uint8 quality) async {
    final file = File(fileName);
    final destination = "...";
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final fileType = _getFileExt(fileName);
    if (!_validate(fileType)) {

      return;
    }
    switch (fileType) {
        case "jpg":
        case "jpeg": {
          final compressed = img.encodeJpg(image, quality: 70);
          await File(destination).writeAsBytes(compressed);
          break;
        }
        case "png": {
          // level: min = 0, max = 9, default = 6
          final compressed = img.encodePng(image, level: 6);
          await File(destination).writeAsBytes(compressed);
          break;
        }
        default: {
          // error here...
          return;
        }
    }
  }

  String _getFileExt(String fileName) {
    return fileName.split(".").last.toLowerCase();
  }

  bool _validate(String ext) {
    return fileTypes.contains(ext);
  }
}