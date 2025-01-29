import 'package:json_annotation/json_annotation.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';

part 'corte_cerebro.g.dart';

@JsonSerializable()
class CorteCerebro {
  @JsonKey()
  final String id;

  @JsonKey()
  final String nombre;

  @JsonKey()
  final String realImage;

  @JsonKey()
  final List<SegmentoCerebro> segmentos;

  CorteCerebro({
    required this.id,
    required this.nombre,
    required this.segmentos,
    required this.realImage,
  });

  factory CorteCerebro.fromJson(Map<String, dynamic> json) =>
      _$CorteCerebroFromJson(json);

  Map<String, dynamic> toJson() => _$CorteCerebroToJson(this);
}
