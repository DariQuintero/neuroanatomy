import 'package:flutter/material.dart';
import 'package:neuroanatomy/json_converters/path_converter.dart';

import 'package:json_annotation/json_annotation.dart';

part 'segmento_cerebro.g.dart';

@JsonSerializable()
class SegmentoCerebro {
  @JsonKey()
  final String id;

  @JsonKey()
  final String nombre;

  @SvgPathConverter()
  final Path path;

  SegmentoCerebro({
    required this.id,
    required this.nombre,
    required this.path,
  });

  factory SegmentoCerebro.fromJson(Map<String, dynamic> json) =>
      _$SegmentoCerebroFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentoCerebroToJson(this);
}
