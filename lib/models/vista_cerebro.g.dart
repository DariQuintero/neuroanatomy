// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vista_cerebro.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VistaCerebro _$VistaCerebroFromJson(Map<String, dynamic> json) => VistaCerebro(
      toCorteId: json['toCorteId'] as String,
      path: const SvgPathConverter().fromJson(json['path'] as String?),
    );

Map<String, dynamic> _$VistaCerebroToJson(VistaCerebro instance) =>
    <String, dynamic>{
      'toCorteId': instance.toCorteId,
      'path': const SvgPathConverter().toJson(instance.path),
    };
