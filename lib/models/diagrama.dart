import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'diagrama.g.dart';

enum DiagramaType {
  @JsonValue('vias')
  vias(title: "Diagramas de vías", value: "vias"),
  @JsonValue('subcorticales')
  subcorticales(title: "Zonas subcorticales", value: "subcorticales");

  final String title;
  final String value;

  const DiagramaType({required this.title, required this.value});
}

@JsonSerializable()
class Diagrama extends Equatable {
  @JsonKey()
  final String nombre;

  @JsonKey()
  final String imageUrl;

  @JsonKey()
  final DiagramaType type;

  const Diagrama({
    required this.nombre,
    required this.imageUrl,
    required this.type,
  });

  factory Diagrama.fromJson(Map<String, dynamic> json) =>
      _$DiagramaFromJson(json);

  Map<String, dynamic> toJson() => _$DiagramaToJson(this);

  @override
  List<Object?> get props => [
        nombre,
        imageUrl,
        type,
      ];
}
