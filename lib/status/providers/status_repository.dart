import 'dart:io';

import 'package:chat_app/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import '../models/status_model.dart';

class StatusRepository {
  StatusRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _statusCol =>
      _firestore.collection('statuses');

  Future<void> uploadStatus({
    required AppUser user,
    required File file,
    required bool isVideo,
  }) async {
    final ext = p.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';

    final ref = _storage
        .ref()
        .child('statuses')
        .child(user.uid)
        .child(fileName);

    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    final docRef = _statusCol.doc();

    final status = StatusModel(
      id: docRef.id,
      uid: user.uid,
      userName: user.name,
      userImage: user.image,
      mediaUrl: downloadUrl,
      isVideo: isVideo,
      text: null,                // ✅ media status has no text
      timestamp: DateTime.now(),
      viewedBy: const [],
    );

    await docRef.set(status.toMap());
  }

  // ✅ NEW: TEXT-ONLY STATUS (no file upload)
  Future<void> uploadTextStatus({
    required AppUser user,
    required String text,
  }) async {
    final docRef = _statusCol.doc();

    final status = StatusModel(
      id: docRef.id,
      uid: user.uid,
      userName: user.name,
      userImage: user.image,
      mediaUrl: '',              // no media URL
      isVideo: false,
      text: text,                // ✅ store the text here
      timestamp: DateTime.now(),
      viewedBy: const [],
    );

    await docRef.set(status.toMap());
  }

  Stream<List<StatusModel>> getStatusesStream() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));

    return _statusCol
        .where('timestamp', isGreaterThan: cutoff)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StatusModel.fromDoc(doc))
              .toList(),
        );
  }

  Future<void> markStatusViewed({
    required String statusId,
    required String viewerUid,
  }) async {
    await _statusCol.doc(statusId).update({
      'viewedBy': FieldValue.arrayUnion([viewerUid]),
    });
  }

  Future<void> deleteExpiredStatuses() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));

    final querySnapshot = await _statusCol
        .where('timestamp', isLessThanOrEqualTo: cutoff)
        .get();

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final mediaUrl = data['mediaUrl'] as String?;

      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(mediaUrl);
          await ref.delete();
        } catch (e) {
          print(e);
        }
      }

      await doc.reference.delete();
    }
  }
}
