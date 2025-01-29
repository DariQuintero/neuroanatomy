import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:neuroanatomy/models/quiz.dart';

class ChatGPTService {
  static Future<Quiz> generateQuiz(String text) async {
    final quizSystem = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'When I send <<<text>>>, create a small quiz. Each question has 4 short answers. Answer json format: {"q":[{"q":"question","a":["correct","answer2","answer3","answer4"]}]}. Answer length <500 chars, avoid spaces/linebreaks.')
      ],
      role: OpenAIChatMessageRole.system,
    );

    final quizResponse = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo-1106',
      responseFormat: {"type": "json_object"},
      messages: [
        quizSystem,
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(text)
          ],
          role: OpenAIChatMessageRole.user,
        )
      ],
      temperature: 0,
    );

    final quizStr = quizResponse.choices.last.message.content?.first.text;

    if (quizStr == null) {
      throw Exception('Quiz not generated');
    }

    final quizJson = json.decode(quizStr);
    // set 'rightAnswer' to each question
    quizJson['q'].forEach((question) {
      question['rightAnswer'] = question['a'][0];
      question['a'].shuffle();
    });

    return Quiz.fromJson(quizJson);
  }
}
