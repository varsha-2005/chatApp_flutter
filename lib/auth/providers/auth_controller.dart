import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';

class AuthController {
  final AuthRepository repo;
  AuthController(this.repo);

  User? get currentUser => repo.currentUser;

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await repo.signup(
        name: name,
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await repo.login(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await repo.resetPassword(email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> googleSignIn() async {
    try {
      await repo.googleSignIn();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() => repo.logout();
}
