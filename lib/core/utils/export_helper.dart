import 'dart:typed_data';
import 'export_helper_io.dart'
    if (dart.library.js_interop) 'export_helper_web.dart' as platform_impl;

class ExportHelper {
  static void downloadImage(Uint8List bytes, String filename) {
    platform_impl.platformDownloadImage(bytes, filename);
  }
}
