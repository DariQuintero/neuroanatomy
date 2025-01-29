import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

enum ActivityType {
  @JsonValue('quiz')
  quiz,
  @JsonValue('definition')
  definition,
}

@JsonSerializable()
class Activity extends Equatable {
  @JsonKey()
  final String? id;

  @JsonKey()
  final ActivityType type;

  @JsonKey()
  final String rawContent;

  const Activity({
    this.id,
    required this.type,
    required this.rawContent,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  @override
  List<Object?> get props => [
        id,
        type,
        rawContent,
      ];
}
