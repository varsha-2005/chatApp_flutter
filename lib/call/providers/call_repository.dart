import 'package:chat_app/call/models/call_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final callRepositoryProvider = Provider(
  (ref) => CallRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class CallRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CallRepository({
    required this.firestore,
    required this.auth,
  });

  /// 1. Save the call history to Firestore
  /// Note: We save to a global 'call' collection, but strictly speaking
  /// for a chat app, you might want to save it to users/{uid}/history
  Future<void> makeCall(CallModel call) async {
    try {
      await firestore.collection('call').doc(call.callId).set(call.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// 2. Get the list of calls (Incoming & Outgoing)
  Stream<List<CallModel>> getCallHistory() {
    // This is a simple query. For a production app, you might need
    // to merge two streams (callerId == uid AND receiverId == uid)
    // or use a 'participants' array.
    // For now, let's fetch calls where the current user is the caller.
    
    return firestore
        .collection('call')
        .where('callerId', isEqualTo: auth.currentUser!.uid)
        .snapshots()
        .map((event) {
      List<CallModel> calls = [];
      for (var document in event.docs) {
        calls.add(CallModel.fromMap(document.data()));
      }
      return calls;
    });
  }
  
  // Helper to get current User ID if needed
  String get currentUid => auth.currentUser!.uid;
}