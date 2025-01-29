import 'package:neuroanatomy/models/segmento_cerebro.dart';

class IlustracionCerebro {
  final String nombre;
  final String realPath;
  final List<SegmentoCerebro> segmentos;

  IlustracionCerebro({
    required this.nombre,
    required this.realPath,
    required this.segmentos,
  });
}
