import 'dart:convert';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void platformDownloadImage(Uint8List bytes, String filename) {
  final base64Data = base64Encode(bytes);
  final url = 'data:image/png;base64,$base64Data';
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
}
