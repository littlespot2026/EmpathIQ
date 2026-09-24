import 'dart:io';
import 'package:flutter/foundation.dart';

void platformDownloadImage(Uint8List bytes, String filename) {
  try {
    // For Desktop / Mobile without web
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$filename');
    file.writeAsBytesSync(bytes);
    debugPrint('[EmpathIQ Export] Saved poster to: ${file.path}');
  } catch (e) {
    debugPrint('[EmpathIQ Export] IO save failed: $e');
  }
}
