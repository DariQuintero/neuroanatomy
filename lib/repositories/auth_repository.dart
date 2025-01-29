import 'package:firebase_auth/firebase_auth.dart';
import 'package:neuroanatomy/services/user_service.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credentials.user!;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await UsersService().createUser(credentials.user!.uid, email: email);
      return credentials.user!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
      } else if (e.code == 'email-already-in-use') {}
    } catch (e) {
      throw Exception(e);
    }
    return null;
  }

  Future<User?> updateName(String name) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await UsersService().updateUser(user.uid, name: name);
        final updatedUser = _firebaseAuth.currentUser;
        return updatedUser;
      }
    } catch (e) {
      throw Exception(e);
    }
    return null;
  }

  Future<User?> updatePassword(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updatePassword(password);
        final updatedUser = _firebaseAuth.currentUser;
        return updatedUser;
      }
    } catch (e) {
      throw Exception(e);
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }

  User? get currentUser => _firebaseAuth.currentUser;
}
