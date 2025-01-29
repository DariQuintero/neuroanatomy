import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:neuroanatomy/pages/auth_page/widgets/auth_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Page'),
      ),
      body: BlocBuilder<AuthCubit, FirebaseAuthState>(
        builder: (context, state) {
          return AuthForm(state: state);
        },
      ),
    );
  }
}
