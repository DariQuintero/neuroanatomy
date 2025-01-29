import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class SvgPathConverter implements JsonConverter<Path, String?> {
  const SvgPathConverter();

  @override
  Path fromJson(String? path) {
    if (path == null) return Path();
    return parseSvgPath(path);
  }

  @override
  String? toJson(Path object) => null;
}
