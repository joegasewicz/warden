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
    "tiff",
  ];
  /// quality can be set from 1-100 - default 80
  int quality = 80;

  FileCompressor({required this.quality}) {
    quality = quality.clamp(1, 100).toInt();
  }

  Future<void> compress(String filename) async {
    final file = File(filename);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final fileType = _getFileExt(filename);
    if (!_validate(fileType)) {

      return;
    }
    switch (fileType) {
        case "jpg":
        case "jpeg": {
          final compressed = img.encodeJpg(image, quality: quality);
          await File(filename).writeAsBytes(compressed);
          break;
        }
        case "png": {
          // level: min = 0, max = 9, default = 6
          final compressed = img.encodePng(image, level: _round());
          await File(filename).writeAsBytes(compressed);
          break;
        }
        case "gif": {
          final compressed = img.encodeGif(image);
          await File(filename).writeAsBytes(compressed);
          break;
        }
        case "bmp": {
          final compressed = img.encodeBmp(image);
          await File(filename).writeAsBytes(compressed);
          break;
        }
        case "tga": {
           final compressed = img.encodeTga(image);
           await File(filename).writeAsBytes(compressed);
           break;
        }
        case "tiff": {
           final compressed = img.encodeTiff(image);
           await File(filename).writeAsBytes(compressed);
           break;
        }
        default: {
          // No op...
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

  int _round() {
    return ((100 - quality) / 100 * 9).round().clamp(0, 9).toInt();
  }
}