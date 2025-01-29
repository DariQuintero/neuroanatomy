import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/pages/auth_page/widgets/auth_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, FirebaseAuthState>(
        builder: (context, state) {
          return Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/logo_with_text.png',
                height: 160,
              ),
              const Spacer(flex: 1),
              AuthForm(state: state),
              const Spacer(flex: 3),
            ],
          );
        },
      ),
    );
  }
}
