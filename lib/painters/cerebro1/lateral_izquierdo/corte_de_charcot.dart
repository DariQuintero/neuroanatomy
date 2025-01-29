import 'package:flutter/material.dart';

class CorteDeCharcot extends CustomPainter {
  Path corte = Path();
  @override
  void paint(Canvas canvas, Size size) {
    // I have this in svg:
    // this is a continues path, we need a dashed path
    // corte.moveTo(size.width * 0.5032, size.height * 0.0);
    // corte.lineTo(size.width * 0.5032, size.height * 1.0);
    // create a dashed path
    for (double i = 0; i < size.height; i += 15) {
      corte.moveTo(size.width * 0.5032, i);
      corte.lineTo(size.width * 0.5032, i + 5);
    }
    // draw the dashed path
    canvas.drawPath(
      corte,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool hitTest(Offset position) {
    // corte is a line, so it has no area, lets add some area to it, 20px at each side
    // so make a new path with the same line and inflate it
    final corteWithArea = Path()
      ..moveTo(corte.getBounds().left - 20, corte.getBounds().top - 20)
      ..lineTo(corte.getBounds().right + 20, corte.getBounds().top - 20)
      ..lineTo(corte.getBounds().right + 20, corte.getBounds().bottom + 20)
      ..lineTo(corte.getBounds().left - 20, corte.getBounds().bottom + 20)
      ..close();
    return corteWithArea.contains(position);
  }
}
