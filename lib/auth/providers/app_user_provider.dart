import 'package:chat_app/auth/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_provider.dart';

final appUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authProvider);
  final user = auth.currentUser;

  if (user == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return AppUser.fromMap(doc.data()!);
      });
});
