import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static String get openAIAPIKey => dotenv.env['OPEN_AI_API_KEY'] ?? '';
}
