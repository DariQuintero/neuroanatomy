import 'package:flutter/material.dart';

class VistaPainter extends CustomPainter {
  final Path vista;
  final Size cerebroSize;

  Path scaledPath = Path();

  VistaPainter({
    required this.vista,
    required this.cerebroSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final relation = size.width / cerebroSize.width;
    scaledPath = vista;
    scaledPath = vista.transform(Matrix4.diagonal3Values(
      relation,
      relation,
      1,
    ).storage);

    final paint = Paint()
      ..color = Colors.lightGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(scaledPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    // the path is just a line so
    // first get the x1, y1, x2, y2 of the line
    final pathBounds = scaledPath.getBounds();
    // create a path but with small padding
    const padding = 10;
    final pathWithArea = Path()
      ..moveTo(pathBounds.left - padding, pathBounds.top - padding)
      ..lineTo(pathBounds.right + padding, pathBounds.top - padding)
      ..lineTo(pathBounds.right + padding, pathBounds.bottom + padding)
      ..lineTo(pathBounds.left - padding, pathBounds.bottom + padding)
      ..close();
    return pathWithArea.contains(position);
  }
}
