import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // ---------------- SIGN UP ----------------
  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    final user = AppUser(
      uid: cred.user!.uid,
      name: name,
      email: email,
      image: 'assets/google_logo.png',
      lastSeen: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  // ---------------- LOGIN ----------------
  Future<void> login({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ---------------- RESET PASSWORD ----------------
  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // ---------------- GOOGLE SIGN-IN ----------------
  Future<void> googleSignIn() async {
    final googleSignIn = GoogleSignIn.instance;
    final googleUser = await googleSignIn.authenticate();

    if (googleUser == null) throw Exception("Sign in aborted");

    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    final user = userCredential.user;
    if (user == null) throw Exception("Firebase auth failed");

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      final newUser = AppUser(
        uid: user.uid,
        name: user.displayName ?? "Unknown User",
        email: user.email ?? "",
        image: user.photoURL ?? "assets/google_logo.png",
        lastSeen: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() {
    return _auth.signOut();
  }
}
