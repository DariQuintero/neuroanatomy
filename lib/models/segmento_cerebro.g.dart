// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segmento_cerebro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SegmentoCerebro _$SegmentoCerebroFromJson(Map<String, dynamic> json) =>
    SegmentoCerebro(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      path: const SvgPathListConverter().fromJson(json['path'] as List),
    );

Map<String, dynamic> _$SegmentoCerebroToJson(SegmentoCerebro instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'path': const SvgPathListConverter().toJson(instance.path),
    };
