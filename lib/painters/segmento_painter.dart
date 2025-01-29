import 'package:flutter/material.dart';

class SegmentoPainter extends CustomPainter {
  final Path segmento;
  final bool isHighlighted;
  final Size cerebroSize;

  Path scaledPath = Path();

  SegmentoPainter({
    required this.segmento,
    required this.isHighlighted,
    required this.cerebroSize,
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
      ..color = Colors.blue.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // print the path to the console

    canvas.drawPath(scaledPath, paint);

    // show the border of the canvas
    final borderPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      borderPaint,
    );
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
