import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/chat/models/chat_room_model.dart';
import 'package:chat_app/chat/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<ChatRoom>> getAllRooms() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('chatRooms')
        .where('members', arrayContains: uid)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ChatRoom.fromMap(doc.data())).toList(),
        );
  }

  Stream<List<AppUser>> getAllUsers() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
    });
  }

  Stream<List<ChatMessage>> getMessages(String roomId) {
    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ChatMessage.fromMap(d.data())).toList(),
        );
  }

  Future<String> createGroupRoom(
    List<String> memberUids,
    String groupName,
  ) async {
    final roomId = _firestore
        .collection('chatRooms')
        .doc()
        .id; // auto ID for group

    final room = ChatRoom(
      roomId: roomId,
      members: memberUids,
      isGroup: true,
      groupName: groupName,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('chatRooms').doc(roomId).set(room.toMap());

    return roomId;
  }

  Future<String> createOrGetRoom(String otherUid) async {
    final myUid = _auth.currentUser!.uid;

    final roomId = myUid == otherUid
        ? "${myUid}_$myUid"
        : myUid.hashCode <= otherUid.hashCode
            ? "${myUid}_$otherUid"
            : "${otherUid}_$myUid";

    final doc = _firestore.collection('chatRooms').doc(roomId);

    if (!(await doc.get()).exists) {
      final room = ChatRoom(
        roomId: roomId,
        members: [myUid, otherUid],
        isGroup: false,
        createdAt: DateTime.now(),
      );
      await doc.set(room.toMap());
    }
    return roomId;
  }

  Future<void> sendMessage({
    required String roomId,
    required String text,
  }) async {
    final myUid = _auth.currentUser!.uid;
    final msgRef = _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: msgRef.id,
      roomId: roomId,
      senderId: myUid,
      message: text,
      timeSent: DateTime.now(),
      isSeen: false,
      imageUrl: null,
      seenBy: [],
    );
    await msgRef.set(message.toMap());
  }

  // 🧹 Clear all messages in a room, but keep the chat room & contact
  Future<void> clearChat(String roomId) async {
    final messagesRef = _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages');

    final snapshot = await messagesRef.get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // 🗑 Delete a single message
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // ✏ Edit a single message (text only)
  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) async {
    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'message': newText});
  }
}
