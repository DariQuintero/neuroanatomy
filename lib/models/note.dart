import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:neuroanatomy/models/activity.dart';

part 'note.g.dart';

@JsonSerializable()
class Note extends Equatable {
  @JsonKey()
  final String? id;

  @JsonKey()
  final String title;

  @JsonKey()
  final String content;

  @JsonKey()
  final String structureId;

  @JsonKey()
  final DateTime? createdAt;

  @JsonKey()
  final DateTime? updatedAt;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.structureId,
    this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        structureId,
        createdAt,
        updatedAt,
      ];
}
