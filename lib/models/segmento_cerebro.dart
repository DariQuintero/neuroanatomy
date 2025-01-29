import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:neuroanatomy/json_converters/path_converter.dart';

import 'package:json_annotation/json_annotation.dart';

part 'segmento_cerebro.g.dart';

@JsonSerializable()
class SegmentoCerebro extends Equatable {
  @JsonKey()
  final String id;

  @JsonKey()
  final String nombre;

  @SvgPathConverter()
  final Path path;

  const SegmentoCerebro({
    required this.id,
    required this.nombre,
    required this.path,
  });

  factory SegmentoCerebro.fromJson(Map<String, dynamic> json) =>
      _$SegmentoCerebroFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentoCerebroToJson(this);

  @override
  List<Object?> get props => [
        id,
        nombre,
        path,
      ];
}
