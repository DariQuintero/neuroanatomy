import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/quiz_cubit/quiz_cubit.dart';
import 'package:neuroanatomy/models/note.dart';

class QuizaPage extends StatelessWidget {
  final List<Note> notes;
  const QuizaPage({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: BlocProvider<QuizCubit>(
        create: (context) =>
            QuizCubit()..generateQuiz(notes.map((e) => e.content).join(' ')),
        child: _QuizPageDisplay(),
      ),
    );
  }
}

class _QuizPageDisplay extends StatefulWidget {
  _QuizPageDisplay();

  @override
  State<_QuizPageDisplay> createState() => _QuizPageDisplayState();
}

class _QuizPageDisplayState extends State<_QuizPageDisplay> {
  int _currentIndex = 0;
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _pageController.addListener(() {
      setState(() {
        _currentIndex = (_pageController.page ?? 0).toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      builder: (context, state) {
        if (state is QuizLoaded) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: state.quiz.questions.length,
                    itemBuilder: (context, index) {
                      final question = state.quiz.questions[index];
                      final questionAlreadyAnswered =
                          question.selectedAnswer != null;
                      return Column(
                        children: [
                          const Spacer(),
                          Center(
                            child: Text(
                              question.question,
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (question.answers.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: question.answers.length,
                              itemBuilder: (context, index) {
                                final tileAnswer = question.answers[index];
                                final isTileAnswerCorrect =
                                    tileAnswer == question.rightAnswer;
                                final isTileSelectedAnswer =
                                    tileAnswer == question.selectedAnswer;

                                return ListTile(
                                  title: Text(
                                    tileAnswer.toUpperCase(),
                                    style: TextStyle(
                                        color: isTileSelectedAnswer
                                            ? Colors.white
                                            : null),
                                  ),
                                  onTap: () {
                                    if (question.selectedAnswer != null) {
                                      return;
                                    }
                                    context
                                        .read<QuizCubit>()
                                        .answerQuestion(question, tileAnswer);
                                  },
                                  tileColor: isTileSelectedAnswer
                                      ? Theme.of(context).primaryColor
                                      : null,
                                  trailing: questionAlreadyAnswered
                                      ? Icon(
                                          isTileAnswerCorrect
                                              ? Icons.check
                                              : Icons.close,
                                          color: isTileAnswerCorrect
                                              ? Colors.green
                                              : Colors.red,
                                        )
                                      : null,
                                );
                              },
                            ),
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _currentIndex > 0 ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Atras'),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );

                            if (_currentIndex ==
                                state.quiz.questions.length - 1) {
                              final correctAnswers = state.quiz.questions
                                  .where((q) => q.isCorrect)
                                  .length;

                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Resultados'),
                                    content: Text(
                                      'Tuviste $correctAnswers respuestas correctas de ${state.quiz.questions.length}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text(
                              _currentIndex < state.quiz.questions.length - 1
                                  ? 'Siguiente'
                                  : 'Terminar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (state is QuizLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is QuizError) {
          return Center(
            child: Text(state.message),
          );
        } else {
          return const Center(
            child: Text('Error desconocido'),
          );
        }
      },
    );
  }
}
