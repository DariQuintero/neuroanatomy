import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/pages/auth_page/auth_page.dart';
import 'package:neuroanatomy/pages/home_page/home_page.dart';
import 'package:neuroanatomy/pages/notes_page/notes_page.dart';
import 'package:neuroanatomy/pages/prueba/prueba.dart';
import 'package:neuroanatomy/repositories/auth_repository.dart';
import 'package:neuroanatomy/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'NeuroAnatomy',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NeuroAnatomy());
}

class NeuroAnatomy extends StatelessWidget {
  const NeuroAnatomy({Key? key}) : super(key: key);

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
