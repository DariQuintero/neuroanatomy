import 'package:flutter/material.dart';
import 'package:neuroanatomy/cubits/auth_cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuroanatomy/extensions/context_extension.dart';
import 'package:neuroanatomy/theme.dart';
import 'package:neuroanatomy/widgets/loading_button.dart';

class AuthForm extends StatefulWidget {
  final FirebaseAuthState state;
  const AuthForm({super.key, required this.state});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool isLogin = true;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
      ),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: roundedTextInputDecoration.copyWith(
              labelText: 'Email',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            decoration: roundedTextInputDecoration.copyWith(
              labelText: 'Contraseña',
            ),
            obscureText: true,
          ),
          if (!isLogin) ...[
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: roundedTextInputDecoration.copyWith(
                labelText: 'Confirmar contraseña',
              ),
              obscureText: true,
            ),
          ],
          const SizedBox(height: 12),
          LoadingButton(
            width: context.mediaQuery.size.width,
            color: context.theme.primaryColor,
            isLoading: isLoading,
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              try {
                if (isLogin) {
                  await context.read<AuthCubit>().login(
                        emailController.text,
                        passwordController.text,
                      );
                } else {
                  if (confirmPasswordController.text ==
                      passwordController.text) {
                    await context.read<AuthCubit>().signUp(
                          emailController.text,
                          passwordController.text,
                        );
                  }
                }
              } finally {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              }
            },
            child: Text(
              isLogin ? 'Iniciar Sesión' : 'Regístrate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (widget.state is AuthFailure) ...[
            const SizedBox(height: 12),
            Text(
              (widget.state as AuthFailure).message,
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: context.theme.colorScheme.tertiary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildToggleIntructions(),
        ],
      ),
    );
  }

  Widget _buildToggleIntructions() {
    final questionText =
        isLogin ? '¿No tienes una cuenta?' : '¿Ya tienes una cuenta?';
    final buttonText = isLogin ? 'Regístrate' : 'Ingresa';
    return Column(
      children: [
        Text(
          questionText,
          style: context.theme.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(
            buttonText,
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
