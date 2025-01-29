import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:neuroanatomy/models/corte_cerebro.dart';

class DisplayableImage {
  final ui.Image image;
  final Uint8List bytes;
  final ImageMode mode;

  const DisplayableImage({
    required this.image,
    required this.bytes,
    required this.mode,
  });
}
