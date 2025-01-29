// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) => QuizQuestion(
      question: json['q'] as String,
      answers: (json['a'] as List<dynamic>).map((e) => e as String).toList(),
      selectedAnswer: json['id'] as String?,
      rightAnswer: json['rightAnswer'] as String,
    );

Map<String, dynamic> _$QuizQuestionToJson(QuizQuestion instance) =>
    <String, dynamic>{
      'q': instance.question,
      'a': instance.answers,
      'id': instance.selectedAnswer,
      'rightAnswer': instance.rightAnswer,
    };
