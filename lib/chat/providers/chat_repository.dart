import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/chat/models/chat_room_model.dart';
import 'package:chat_app/chat/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  // return _firestore
  // .collection("users")
  // .snapshots()
  // .map(
  //   (snapshot) =>
  //     snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList()
  // );

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
      groupImage: null,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('chatRooms').doc(roomId).set(room.toMap());

    return roomId;
  }

  Future<void> updateGroupImage({
    required String roomId,
    required File file,
  }) async {
    final ext = p.extension(file.path);
    final ref = _storage
        .ref()
        .child('groupImages')
        .child(roomId)
        .child('group$ext');

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await _firestore.collection('chatRooms').doc(roomId).update({
      'groupImage': url,
    });
  }

  Stream<ChatRoom> getRoomStream(String roomId) {
    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .snapshots()
        .map((doc) => ChatRoom.fromMap(doc.data()!));
  }

  Future<void> addMembersToGroup({
    required String roomId,
    required List<String> newMemberUids,
  }) async {
    await _firestore.collection('chatRooms').doc(roomId).update({
      'members': FieldValue.arrayUnion(newMemberUids),
    });
  }

  Future<void> updateGroupName({
    required String roomId,
    required String newName,
  }) async {
    await _firestore.collection('chatRooms').doc(roomId).update({
      'groupName': newName,
    });
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
    final user = _auth.currentUser!;
    final msgRef = _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: msgRef.id,
      roomId: roomId,
      senderId: user.uid,
      senderName: user.displayName ?? "Unknown", // ✅ ADD
      message: text,
      imageUrl: null,
      isVideo: false,
      timeSent: DateTime.now(),
      isSeen: false,
      seenBy: [],
    );

    await msgRef.set(message.toMap());
  }

  Future<void> sendMediaMessage({
    required String roomId,
    required File file,
    required bool isVideo,
    String? text,
  }) async {
    // final myUid = _auth.currentUser!.uid;

    // 1️⃣ Upload file to Firebase Storage
    final ext = p.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';

    final ref = _storage.ref().child('chatMedia').child(roomId).child(fileName);

    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // 2️⃣ Create message document
    final msgRef = _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc();

    final user = _auth.currentUser!;

    final message = ChatMessage(
      id: msgRef.id,
      roomId: roomId,
      senderId: user.uid,
      senderName: user.displayName ?? 'Unknown',
      message: text ?? '', // optional caption
      imageUrl: downloadUrl, // ✅ image or video URL
      isVideo: isVideo,
      timeSent: DateTime.now(),
      isSeen: false,
      seenBy: [],
    );

    await msgRef.set(message.toMap());
  }

  Future<void> markMessageSeen({
    required String roomId,
    required String messageId,
    required String uid,
  }) async {
    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({
          'seenBy': FieldValue.arrayUnion([uid]),
        });
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

  Future<void> deleteMessageForMe({
    required String roomId,
    required String messageId,
    required String uid,
  }) async {
    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({
          'seenBy': FieldValue.arrayUnion(['deleted_$uid']),
        });
  }

  Future<void> exitGroup({required String roomId, required String uid}) async {
    await _firestore.collection('chatRooms').doc(roomId).update({
      'members': FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> deleteMessageForEveryone({
    required String roomId,
    required String messageId,
  }) async {
    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({
          'message': 'This message was deleted',
          'imageUrl': null,
          'isVideo': false,
          'deletedForEveryone': true,
        });
  }
}
