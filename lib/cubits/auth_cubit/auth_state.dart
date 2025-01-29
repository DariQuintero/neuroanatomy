part of 'auth_cubit.dart';

abstract class FirebaseAuthState extends Equatable {
  const FirebaseAuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends FirebaseAuthState {}

class AuthLoading extends FirebaseAuthState {
  final String email;
  final String password;

  const AuthLoading({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSuccess extends FirebaseAuthState {
  final User user;

  const AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthProfileUpdating extends AuthSuccess {
  final String? name;
  final String? password;

  const AuthProfileUpdating({
    required super.user,
    this.password,
    this.name,
  });

  @override
  List<Object> get props => [name ?? "", password ?? ""];
}

class AuthFailure extends FirebaseAuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}
