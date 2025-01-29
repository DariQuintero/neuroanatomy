import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuroanatomy/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<FirebaseAuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(AuthInitial()) {
    final user = authRepository.currentUser;
    if (user != null) {
      emit(AuthSuccess(user: user));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading(email: email, password: password));
    try {
      final user = await authRepository.login(email, password);
      if (user != null) emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading(email: email, password: password));
    try {
      final user = await authRepository.signUp(email, password);
      if (user != null) emit(AuthSuccess(user: user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> updateName(String name) async {
    if (state is! AuthSuccess) return;
    final user = (state as AuthSuccess).user;
    emit(AuthProfileUpdating(user: user, name: name));
    try {
      final user = await authRepository.updateName(name);
      emit(AuthSuccess(user: user!));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> updatePassword(String password) async {
    if (state is! AuthSuccess) return;
    final user = (state as AuthSuccess).user;
    emit(AuthProfileUpdating(user: user, password: password));
    try {
      final user = await authRepository.updatePassword(password);
      emit(AuthSuccess(user: user!));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
