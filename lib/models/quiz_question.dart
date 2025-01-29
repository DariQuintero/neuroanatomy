import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_question.g.dart';

@JsonSerializable()
class QuizQuestion extends Equatable {
  @JsonKey(name: 'q')
  final String question;

  @JsonKey(name: 'a')
  final List<String> answers;

  @JsonKey(name: 'id')
  final String? selectedAnswer;

  @JsonKey()
  final String rightAnswer;

  const QuizQuestion({
    required this.question,
    required this.answers,
    required this.selectedAnswer,
    required this.rightAnswer,
  });

  bool get isCorrect => selectedAnswer == rightAnswer;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionToJson(this);

  @override
  List<Object?> get props => [question, answers, selectedAnswer, rightAnswer];

  QuizQuestion copyWith({
    String? question,
    List<String>? answers,
    String? selectedAnswer,
  }) {
    return QuizQuestion(
      question: question ?? this.question,
      answers: answers ?? this.answers,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      rightAnswer: rightAnswer,
    );
  }
}
