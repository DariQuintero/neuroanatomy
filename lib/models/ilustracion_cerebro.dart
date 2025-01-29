import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';

class IlustracionCerebro {
  final String nombre;
  final String realPath;
  final List<SegmentoCerebro> segmentos;
  final List<CorteCerebro> cortes;

  IlustracionCerebro({
    required this.nombre,
    required this.realPath,
    required this.segmentos,
    required this.cortes,
  });
}
