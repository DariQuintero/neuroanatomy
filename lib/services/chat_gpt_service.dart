import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class ChatGPTService {
  late OpenAI _openAI;

  ChatGPTService() {
    _openAI = OpenAI.instance.build(
        token: const String.fromEnvironment('OPENAI_API_KEY'),
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 15)),
        isLog: true);
  }

  Future<String> generateQuizFromText(String text) async {
    await Future.delayed(const Duration(seconds: 1));
    final prompt =
        'I have this text: $text\n Generate a 5 question quiz from this text with open questions';
    final request =
        CompleteText(prompt: prompt, model: Model.TextDavinci3, maxTokens: 200);
    final response = await _openAI.onCompletion(request: request);
    if (response == null) return 'Error';
    return response.choices.first.text;
  }
}
