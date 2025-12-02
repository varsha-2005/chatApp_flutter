import 'package:chat_app/auth/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref),
);

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  FirebaseAuth get _auth => ref.read(authProvider);

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = AppUser(
        uid: cred.user!.uid,
        name: name,
        email: email,
        image: 'assets/google_logo.png',
        lastSeen: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // ✅ FORGOT PASSWORD LOGIC (only added, nothing else changed)
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> googleSignIn() async {
    try {
      // 1️⃣ Trigger Google sign-in (new v7 API)
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      // User closed the popup / backed out
      if (googleUser == null) return 'Sign in aborted';

      // 2️⃣ Get auth details (idToken)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3️⃣ Create Firebase credential using ONLY idToken
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4️⃣ Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // 5️⃣ Save to Firestore if first time
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        final newUser = AppUser(
          uid: user.uid,
          name: user.displayName ?? "Unknown User",
          email: user.email ?? "",
          image: user.photoURL ?? "assets/google_logo.png",
          lastSeen: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());
      }

      return null; // ✅ success
    } on GoogleSignInException catch (e) {
      // return e.errorMessage ?? e.code.toString();
      print(e);
    } catch (e) {
      // any other error
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
