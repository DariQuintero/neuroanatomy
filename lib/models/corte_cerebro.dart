import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/models/vista_cerebro.dart';

part 'corte_cerebro.g.dart';

@JsonSerializable()
class CorteCerebro extends Equatable {
  @JsonKey()
  final String id;

  @JsonKey()
  final String nombre;

  @JsonKey()
  final String realImage;

  @JsonKey()
  final List<SegmentoCerebro> segmentos;

  @JsonKey(defaultValue: [])
  final List<VistaCerebro> vistas;

  @JsonKey()
  final String? derechaId;

  @JsonKey()
  final String? izquierdaId;

  const CorteCerebro({
    required this.id,
    required this.nombre,
    required this.segmentos,
    required this.realImage,
    required this.vistas,
    this.derechaId,
    this.izquierdaId,
  });

  factory CorteCerebro.fromJson(Map<String, dynamic> json) =>
      _$CorteCerebroFromJson(json);

  Map<String, dynamic> toJson() => _$CorteCerebroToJson(this);

  @override
  List<Object?> get props => [
        id,
        nombre,
        segmentos,
        vistas,
        realImage,
        derechaId,
        izquierdaId,
      ];
}
