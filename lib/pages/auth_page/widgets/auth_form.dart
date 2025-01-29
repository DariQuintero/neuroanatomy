import 'package:flutter/material.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthForm extends StatefulWidget {
  final FirebaseAuthState state;
  const AuthForm({super.key, required this.state});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool isLogin = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Spacer(),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          if (!isLogin)
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
          ElevatedButton(
            onPressed: () {
              if (isLogin) {
                context.read<AuthCubit>().login(
                      emailController.text,
                      passwordController.text,
                    );
              } else {
                if (confirmPasswordController.text == passwordController.text) {
                  context.read<AuthCubit>().signUp(
                        emailController.text,
                        passwordController.text,
                      );
                }
              }
            },
            child: Text(isLogin ? 'Login' : 'Sign Up'),
          ),
          widget.state is AuthLoading
              ? const CircularProgressIndicator()
              : TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(isLogin ? 'Sign Up' : 'Login'),
                ),
          const Spacer(),
        ],
      ),
    );
  }
}
