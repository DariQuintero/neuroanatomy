import 'package:flutter/material.dart';

//Copy this CustomPainter code to the Bottom of the File
class GiroTemporalSuperior extends CustomPainter {
  Path contorno = Path();

  final bool highlight;
  GiroTemporalSuperior({this.highlight = false});

  @override
  void paint(Canvas canvas, Size size) {
    contorno.moveTo(size.width * 0.4713680, size.height * 0.5515488);
    contorno.cubicTo(
        size.width * 0.4534093,
        size.height * 0.5571994,
        size.width * 0.4595917,
        size.height * 0.5311457,
        size.width * 0.4441092,
        size.height * 0.5445403);
    contorno.cubicTo(
        size.width * 0.4394645,
        size.height * 0.5485573,
        size.width * 0.4208059,
        size.height * 0.5740099,
        size.width * 0.4170148,
        size.height * 0.5793847);
    contorno.cubicTo(
        size.width * 0.4100583,
        size.height * 0.5892574,
        size.width * 0.3888600,
        size.height * 0.6129632,
        size.width * 0.3819035,
        size.height * 0.6228359);
    contorno.cubicTo(
        size.width * 0.3704030,
        size.height * 0.6391584,
        size.width * 0.3730488,
        size.height * 0.6418317,
        size.width * 0.3646182,
        size.height * 0.6612023);
    contorno.cubicTo(
        size.width * 0.3583351,
        size.height * 0.6756436,
        size.width * 0.3604984,
        size.height * 0.6854597,
        size.width * 0.3492789,
        size.height * 0.6928571);
    contorno.cubicTo(
        size.width * 0.3399099,
        size.height * 0.6990311,
        size.width * 0.3235525,
        size.height * 0.6858062,
        size.width * 0.3181283,
        size.height * 0.6977157);
    contorno.cubicTo(
        size.width * 0.3143054,
        size.height * 0.7061103,
        size.width * 0.3192577,
        size.height * 0.7296464,
        size.width * 0.3244168,
        size.height * 0.7366549);
    contorno.cubicTo(
        size.width * 0.3295758,
        size.height * 0.7436634,
        size.width * 0.3369618,
        size.height * 0.7472702,
        size.width * 0.3441782,
        size.height * 0.7492362);
    contorno.cubicTo(
        size.width * 0.3692736,
        size.height * 0.7560537,
        size.width * 0.3914581,
        size.height * 0.7480622,
        size.width * 0.4052598,
        size.height * 0.7192857);
    contorno.cubicTo(
        size.width * 0.4095334,
        size.height * 0.7103819,
        size.width * 0.4181972,
        size.height * 0.7058911,
        size.width * 0.4232238,
        size.height * 0.6977228);
    contorno.cubicTo(
        size.width * 0.4271898,
        size.height * 0.6912801,
        size.width * 0.4387010,
        size.height * 0.6676450,
        size.width * 0.4438812,
        size.height * 0.6629774);
    contorno.cubicTo(
        size.width * 0.4603075,
        size.height * 0.6481895,
        size.width * 0.4649470,
        size.height * 0.6523126,
        size.width * 0.4813733,
        size.height * 0.6375248);
    contorno.cubicTo(
        size.width * 0.4859862,
        size.height * 0.6333734,
        size.width * 0.4892206,
        size.height * 0.6209618,
        size.width * 0.4946288,
        size.height * 0.6192433);
    contorno.cubicTo(
        size.width * 0.5029374,
        size.height * 0.6166054,
        size.width * 0.5064687,
        size.height * 0.6235856,
        size.width * 0.5148409,
        size.height * 0.6258345);
    contorno.cubicTo(
        size.width * 0.5484305,
        size.height * 0.6348515,
        size.width * 0.5916384,
        size.height * 0.6253041,
        size.width * 0.6162301,
        size.height * 0.5934795);
    contorno.cubicTo(
        size.width * 0.6206893,
        size.height * 0.5877086,
        size.width * 0.6222959,
        size.height * 0.5875601,
        size.width * 0.6247985,
        size.height * 0.5799717);
    contorno.cubicTo(
        size.width * 0.6289130,
        size.height * 0.5674965,
        size.width * 0.6307476,
        size.height * 0.5469943,
        size.width * 0.6299682,
        size.height * 0.5334017);
    contorno.cubicTo(
        size.width * 0.6289979,
        size.height * 0.5165134,
        size.width * 0.6274390,
        size.height * 0.4979208,
        size.width * 0.6181018,
        size.height * 0.4864427);
    contorno.cubicTo(
        size.width * 0.6101644,
        size.height * 0.4766902,
        size.width * 0.5985843,
        size.height * 0.4746747,
        size.width * 0.5877996,
        size.height * 0.4740877);
    contorno.cubicTo(
        size.width * 0.5855779,
        size.height * 0.4739675,
        size.width * 0.5840085,
        size.height * 0.4838967,
        size.width * 0.5822163,
        size.height * 0.4856506);
    contorno.cubicTo(
        size.width * 0.5800954,
        size.height * 0.4877298,
        size.width * 0.5720573,
        size.height * 0.5008133,
        size.width * 0.5714369,
        size.height * 0.5042221);
    contorno.cubicTo(
        size.width * 0.5682980,
        size.height * 0.5214993,
        size.width * 0.5587646,
        size.height * 0.5200636,
        size.width * 0.5470308,
        size.height * 0.5284936);
    contorno.cubicTo(
        size.width * 0.5241941,
        size.height * 0.5448868,
        size.width * 0.4944327,
        size.height * 0.5357284,
        size.width * 0.4713680,
        size.height * 0.5515488);

    contorno.close();
    if (highlight) {
      canvas.drawPath(
        contorno,
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  // on tap insite the contorno
  @override
  bool hitTest(Offset position) {
    return contorno.contains(position);
  }
}
