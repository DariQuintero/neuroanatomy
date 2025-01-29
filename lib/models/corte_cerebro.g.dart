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
      vistas: (json['vistas'] as List<dynamic>?)
              ?.map((e) => VistaCerebro.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aquarelaImage: json['aquarelaImage'] as String?,
      derechaId: json['derechaId'] as String?,
      izquierdaId: json['izquierdaId'] as String?,
      arribaId: json['arribaId'] as String?,
      abajoId: json['abajoId'] as String?,
      atrasId: json['atrasId'] as String?,
    );

Map<String, dynamic> _$CorteCerebroToJson(CorteCerebro instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'realImage': instance.realImage,
      'aquarelaImage': instance.aquarelaImage,
      'segmentos': instance.segmentos,
      'vistas': instance.vistas,
      'derechaId': instance.derechaId,
      'izquierdaId': instance.izquierdaId,
      'arribaId': instance.arribaId,
      'abajoId': instance.abajoId,
      'atrasId': instance.atrasId,
    };
