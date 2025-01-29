import 'package:flutter/material.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';

class SegmentoPainter extends CustomPainter {
  final SegmentoCerebro segmento;
  final bool isHighlighted;
  final Size cerebroSize;
  final Color highlightColor;

  List<Path> scaledPaths = [];

  SegmentoPainter({
    required this.segmento,
    required this.isHighlighted,
    required this.cerebroSize,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final relation = size.width / cerebroSize.width;

    // canvas.drawPath(scaledPath, paint);
    for (var segmento in segmento.path) {
      scaledPaths.add(segmento.transform(Matrix4.diagonal3Values(
        relation,
        relation,
        1,
      ).storage)
        ..close());
    }

    final paint = Paint()
      ..color = isHighlighted ? highlightColor : Colors.transparent
      // ..color = highlightColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    for (var path in scaledPaths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    for (var path in scaledPaths) {
      if (path.contains(position)) {
        return true;
      }
    }
    return false;
  }
}
