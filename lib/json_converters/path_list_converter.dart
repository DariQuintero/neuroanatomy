import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class SvgPathListConverter implements JsonConverter<List<Path>, List<dynamic>> {
  const SvgPathListConverter();

  @override
  List<Path> fromJson(List<dynamic> pathsStr) {
    return pathsStr.map((path) => parseSvgPath(path)).toList();
  }

  @override
  List<dynamic> toJson(List<Path> paths) => [];
}
