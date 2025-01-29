import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:neuroanatomy/models/segmento_cerebro.dart';
import 'package:neuroanatomy/models/vista_cerebro.dart';

part 'corte_cerebro.g.dart';

enum ImageMode { real, aquarela }

@JsonSerializable()
class CorteCerebro extends Equatable {
  @JsonKey()
  final String id;

  @JsonKey()
  final String nombre;

  @JsonKey()
  final String realImage;

  @JsonKey()
  final String? aquarelaImage;

  @JsonKey()
  final List<SegmentoCerebro> segmentos;

  @JsonKey(defaultValue: [])
  final List<VistaCerebro> vistas;

  @JsonKey()
  final String? derechaId;

  @JsonKey()
  final String? izquierdaId;

  @JsonKey()
  final String? arribaId;

  @JsonKey()
  final String? abajoId;

  @JsonKey()
  final String? atrasId;

  const CorteCerebro({
    required this.id,
    required this.nombre,
    required this.segmentos,
    required this.realImage,
    required this.vistas,
    this.aquarelaImage,
    this.derechaId,
    this.izquierdaId,
    this.arribaId,
    this.abajoId,
    this.atrasId,
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
        arribaId,
        abajoId,
        atrasId,
        aquarelaImage,
      ];

  String? imageUrlForMode(ImageMode mode) {
    switch (mode) {
      case ImageMode.real:
        return realImage;
      case ImageMode.aquarela:
        return aquarelaImage;
    }
  }
}
