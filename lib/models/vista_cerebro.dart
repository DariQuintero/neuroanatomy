import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:neuroanatomy/json_converters/path_converter.dart';

part 'vista_cerebro.g.dart';

@JsonSerializable()
class VistaCerebro extends Equatable {
  @JsonKey()
  final String toCorteId;

  @SvgPathConverter()
  final Path path;

  const VistaCerebro({
    required this.toCorteId,
    required this.path,
  });

  factory VistaCerebro.fromJson(Map<String, dynamic> json) =>
      _$VistaCerebroFromJson(json);

  Map<String, dynamic> toJson() => _$VistaCerebroToJson(this);

  @override
  List<Object?> get props => [
        toCorteId,
        path,
      ];
}
