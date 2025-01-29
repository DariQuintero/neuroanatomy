import 'package:flutter/material.dart';

class SegmentoPainter extends CustomPainter {
  final Path segmento;
  final bool isHighlighted;
  final Size cerebroSize;
  final Color highlightColor;

  Path scaledPath = Path();

  SegmentoPainter({
    required this.segmento,
    required this.isHighlighted,
    required this.cerebroSize,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final relation = size.width / cerebroSize.width;
    scaledPath = segmento;
    scaledPath = segmento.transform(Matrix4.diagonal3Values(
      relation,
      relation,
      1,
    ).storage);

    final paint = Paint()
      ..color = isHighlighted ? highlightColor : Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    canvas.drawPath(scaledPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    return scaledPath.contains(position);
  }
}
