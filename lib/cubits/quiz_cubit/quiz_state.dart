part of 'quiz_cubit.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final Quiz quiz;

  const QuizLoaded({required this.quiz});

  @override
  List<Object> get props => [quiz];
}

class QuizFinished extends QuizState {
  final Quiz quiz;
  final int score;

  const QuizFinished({
    required this.quiz,
    required this.score,
  });

  int get totalScore => quiz.questions.length;

  @override
  List<Object> get props => [quiz, score];
}

class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object> get props => [message];
}
