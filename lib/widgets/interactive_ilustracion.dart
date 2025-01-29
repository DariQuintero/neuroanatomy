import 'package:flutter/material.dart';
import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/ilustracion_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';

class InteractiveIlustracion extends StatelessWidget {
  final IlustracionCerebro ilustracion;
  final double width;
  final double aspectRatio;
  final Function(EstructuraCerebro estructura)? onEstructuraTap;
  final Function(CorteCerebro corte)? onCorteTap;
  final bool showCortes;

  const InteractiveIlustracion({
    super.key,
    required this.ilustracion,
    required this.width,
    required this.aspectRatio,
    this.onEstructuraTap,
    this.onCorteTap,
    this.showCortes = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          ilustracion.realPath,
          width: width,
          height: width * aspectRatio,
          fit: BoxFit.cover,
        ),
        ...ilustracion.estructuras.map((estructura) {
          return GestureDetector(
              child: CustomPaint(
                size: Size(width, width * aspectRatio),
                painter: estructura.painter,
              ),
              onTap: () {
                onEstructuraTap?.call(estructura);
              });
        }).toList(),
        if (showCortes)
          ...ilustracion.cortes.map((corte) {
            return GestureDetector(
              child: CustomPaint(
                size: Size(width, width * aspectRatio),
                painter: corte.painter,
              ),
              onTap: () {
                onCorteTap?.call(corte);
              },
            );
          }),
      ],
    );
  }
}
