import 'package:neuroanatomy/models/corte_cerebro.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';

class IlustracionCerebro {
  final String id;
  final String nombre;
  final String realPath;
  final List<SegmentoCerebro> estructuras;
  final List<CorteCerebro> cortes;

  IlustracionCerebro({
    required this.id,
    required this.nombre,
    required this.realPath,
    required this.estructuras,
    required this.cortes,
  });
}
