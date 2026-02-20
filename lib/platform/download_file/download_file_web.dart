import 'dart:convert';
import 'package:web/web.dart';

void downloadFile(
  List<int> bytes, {
  required String name,
  required String extension,
}) {
  // base64Encode is from dart:convert
  final base64 = base64Encode(bytes);

  // Create the link with the file
  // AnchorElement comes from the
  final anchor = HTMLAnchorElement()
    ..href = 'data:application/octet-stream;base64,$base64'
    ..target = 'blank';

  // add the name and extension
  anchor.download = '$name.$extension';

  // add the anchor to the document body
  document.body?.append(anchor);

  // trigger download
  anchor.click();

  // remove the anchor
  anchor.remove();
}
