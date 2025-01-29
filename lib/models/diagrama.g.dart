// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagrama.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Diagrama _$DiagramaFromJson(Map<String, dynamic> json) => Diagrama(
      nombre: json['nombre'] as String,
      imageUrl: json['imageUrl'] as String,
      type: $enumDecode(_$DiagramaTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$DiagramaToJson(Diagrama instance) => <String, dynamic>{
      'nombre': instance.nombre,
      'imageUrl': instance.imageUrl,
      'type': _$DiagramaTypeEnumMap[instance.type]!,
    };

const _$DiagramaTypeEnumMap = {
  DiagramaType.vias: 'vias',
  DiagramaType.subcorticales: 'subcorticales',
};
