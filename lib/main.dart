import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/env/env.dart';
import 'package:neuroanatomy/pages/auth_page/auth_page.dart';
import 'package:neuroanatomy/pages/home_page/home_page.dart';
import 'package:neuroanatomy/repositories/auth_repository.dart';
import 'package:neuroanatomy/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  OpenAI.apiKey = Env.openAIAPIKey;
  await Firebase.initializeApp(
    name: 'NeuroAnatomy',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NeuroAnatomy());
}

class NeuroAnatomy extends StatelessWidget {
  const NeuroAnatomy({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'NeuroAnatomy',
        theme: mainTheme(),
        debugShowCheckedModeBanner: false,
        home: BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepository: context.read<AuthRepository>()),
          child: BlocBuilder<AuthCubit, FirebaseAuthState>(
              builder: (context, state) {
            if (state is AuthSuccess) {
              return Navigator(
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  ];
                },
              );
            } else if (state is AuthFailure ||
                state is AuthInitial ||
                state is AuthLoading) {
              return const AuthPage();
            } else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
