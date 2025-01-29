// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'corte_cerebro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CorteCerebro _$CorteCerebroFromJson(Map<String, dynamic> json) => CorteCerebro(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      segmentos: (json['segmentos'] as List<dynamic>)
          .map((e) => SegmentoCerebro.fromJson(e as Map<String, dynamic>))
          .toList(),
      realImage: json['realImage'] as String,
    );

Map<String, dynamic> _$CorteCerebroToJson(CorteCerebro instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'realImage': instance.realImage,
      'segmentos': instance.segmentos,
    };
