import 'dart:typed_data';
import 'dart:ui' as ui;

class DisplayableImage {
  final ui.Image image;
  final Uint8List bytes;

  const DisplayableImage({
    required this.image,
    required this.bytes,
  });
}
