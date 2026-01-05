import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class CacheHelper {
  /// Get cache size
  static Future<String> getCacheSize() async {
    final directory = await getTemporaryDirectory();
    final folder = Directory(directory.path);
    int totalSize = 0;

    if (folder.existsSync()) {
      final files = folder.listSync(recursive: true, followLinks: false);
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }

    return formatBytes(totalSize, 2);
  }

  /// Clear cache
  static Future<void> clearCache() async {
    final directory = await getTemporaryDirectory();
    final folder = Directory(directory.path);

    if (folder.existsSync()) {
      folder.deleteSync(recursive: true);
    }
  }

  /// Format bytes to human-readable string
  static String formatBytes(int bytes, int decimals) {
    if (bytes == 0) return "0 B";
    const k = 1024;
    final dm = decimals < 0 ? 0 : decimals;
    const sizes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(k)).floor();
    return "${(bytes / pow(k, i)).toStringAsFixed(dm)} ${sizes[i]}";
  }
}
