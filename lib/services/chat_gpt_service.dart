import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:neuroanatomy/models/quiz.dart';

class ChatGPTService {
  static Future<Quiz> generateQuiz(String text) async {
    try {
      final quizResponse = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'When I send text, create a small quiz. Each question has 4 short answers. '
                'Answer in JSON format: {"q":[{"q":"question","a":["correct","answer2","answer3","answer4"]}]}. '
                'Answer length <500 chars, avoid spaces/linebreaks.',
              )
            ],
            role: OpenAIChatMessageRole.system,
          ),
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(text)
            ],
            role: OpenAIChatMessageRole.user,
          )
        ],
        temperature: 0.3,
        maxTokens: 1000,
      );

      final quizStr = quizResponse.choices.first.message.content?.first.text;

      if (quizStr == null || quizStr.isEmpty) {
        throw Exception('Quiz not generated: empty response');
      }

      final quizJson = json.decode(quizStr);

      // Validate response format
      if (quizJson['q'] == null) {
        throw Exception('Invalid quiz format: missing "q" field');
      }

      // set 'rightAnswer' to each question
      for (var question in quizJson['q']) {
        if (question['a'] == null || (question['a'] as List).isEmpty) {
          throw Exception('Invalid question format: missing answers');
        }
        question['rightAnswer'] = question['a'][0];
        question['a'].shuffle();
      }

      return Quiz.fromJson(quizJson);
    } catch (e) {
      throw Exception('Error generating quiz: $e');
    }
  }
}
