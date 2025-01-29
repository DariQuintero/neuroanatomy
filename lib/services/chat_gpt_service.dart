import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:neuroanatomy/models/quiz.dart';

class ChatGPTService {
  static const quizSystem = OpenAIChatCompletionChoiceMessageModel(
    content:
        'When I send <<<text>>>, create a quiz with 2 questions. Each question has 4 short answers. Answer format: {"q":[{"q":"question","a":["correct","answer2","answer3","answer4"]}]}. Answer length <500 chars, avoid spaces/linebreaks.',
    role: OpenAIChatMessageRole.system,
  );

  static const definitionSystem = OpenAIChatCompletionChoiceMessageModel(
    content:
        'When I send <<<text>>> you recognize terms and definitions. Answer format: {"d":[{"t":"term","d":"definition"}]}. answer_length<500 chars,avoid spaces/linebreaks.max 5 terms.',
    role: OpenAIChatMessageRole.system,
  );

  static Future<Quiz> generateQuiz(String text) async {
    final quizResponse = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      messages: [
        definitionSystem,
        OpenAIChatCompletionChoiceMessageModel(
          content: "<<<$text>>>",
          role: OpenAIChatMessageRole.user,
        )
      ],
      temperature: 0,
    );

    final quizStr = quizResponse.choices.last.message.content;

    final quizJson = json.decode(quizStr);

    return Quiz.fromJson(quizJson);
  }
}
