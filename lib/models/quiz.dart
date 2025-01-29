import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:neuroanatomy/models/quiz_question.dart';

part 'quiz.g.dart';

@JsonSerializable()
class Quiz extends Equatable {
  @JsonKey(name: 'q')
  final List<QuizQuestion> questions;

  const Quiz({
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  Map<String, dynamic> toJson() => _$QuizToJson(this);

  @override
  List<Object?> get props => [questions];
}
