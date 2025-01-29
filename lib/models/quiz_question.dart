import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_question.g.dart';

@JsonSerializable()
class QuizQuestion extends Equatable {
  @JsonKey()
  final String question;

  @JsonKey()
  final List<String> answers;

  String get rightAnswer => answers.first;

  bool isRightAnswer(String answer) {
    return rightAnswer.compareTo(answer) == 0;
  }

  const QuizQuestion({
    required this.question,
    required this.answers,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);

  @override
  List<Object?> get props => [question, answers];
}
