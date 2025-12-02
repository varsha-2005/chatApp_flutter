import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/settings/models/user_setting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Stream<AppUser> watchUserProfile() {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => AppUser.fromMap(snapshot.data()!));
  }

  Stream<UserSetting> watchUserSettings() {
    return _firestore
        .collection("users")
        .doc(uid)
        .collection("settings")
        .doc("prefs")
        .snapshots()
        .map(
          (doc) => doc.exists
              ? UserSetting.fromMap(doc.data()!)
              : UserSetting(readChats: true),
        );
  }

  Future<void> updateName(String newName) async {
    await _firestore.collection("users").doc(uid).update({"name": newName});
  }

  Future<void> updateProfileImage(String imageUrl) async {
    await _firestore.collection("users").doc(uid).update({"image": imageUrl});
  }

  Future<String> uploadAndSetProfileImage(File file) async {
    final ext = p.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_profile_images')
        .child(fileName);

    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    await updateProfileImage(downloadUrl);
    return downloadUrl;
  }

  Future<void> upadteReadChats(bool value) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("settings")
        .doc("prefs")
        .set({
          "readChats": value,
        }, SetOptions(merge: true)); // so it doesn't overwrite darkMode
  }

  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");

    await user.updatePassword(newPassword);

    await _firestore.collection("users").doc(uid).update({
      "passwordChangedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> upadteDarkMode(bool value) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("settings")
        .doc("prefs")
        .set({"darkMode": value}, SetOptions(merge: true));
  }
}
