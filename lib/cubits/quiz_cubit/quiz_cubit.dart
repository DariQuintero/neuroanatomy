import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/models/quiz.dart';
import 'package:neuroanatomy/models/quiz_question.dart';
import 'package:neuroanatomy/services/chat_gpt_service.dart';

part 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit() : super(QuizInitial());

  Future<void> generateQuiz(String text) async {
    emit(QuizLoading());
    try {
      final quiz = await ChatGPTService.generateQuiz(text);
      emit(QuizLoaded(quiz: quiz));
    } catch (e) {
      emit(QuizError(message: e.toString()));
    }
  }

  Future<void> answerQuestion(QuizQuestion quiestion, String answer) async {
    final state = this.state;
    if (state is QuizLoaded) {
      final answeredQuestion = quiestion.copyWith(selectedAnswer: answer);

      final answeredQuestions = [
        ...state.quiz.questions.map((q) {
          if (q == quiestion) {
            return answeredQuestion;
          }
          return q;
        })
      ];

      emit(
        QuizLoaded(
          quiz: state.quiz.copyWith(questions: answeredQuestions),
        ),
      );
    }
  }
}
