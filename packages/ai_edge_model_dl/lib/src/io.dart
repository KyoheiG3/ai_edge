import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Abstract class for file system operations
abstract class IO {
  File createFile(String path);
  Directory createDirectory(String path);
  Future<String> getBaseDirectory();
}

/// Default implementation using dart:io
class DefaultIO implements IO {
  const DefaultIO();

  @override
  File createFile(String path) {
    return File(path);
  }

  @override
  Directory createDirectory(String path) {
    return Directory(path);
  }

  @override
  Future<String> getBaseDirectory() async {
    final Directory appDir;

    if (Platform.isAndroid) {
      // Try external storage on Android for better space availability
      final externalDir = await getExternalStorageDirectory();
      appDir = externalDir ?? await getApplicationSupportDirectory();
    } else {
      // Use Application Support directory to avoid backups
      // Models are downloaded content that can be re-downloaded if needed
      appDir = await getApplicationSupportDirectory();
    }

    return appDir.path;
  }
}
