import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/chat/models/chat_room_model.dart';
import 'package:chat_app/chat/models/message_model.dart';
import 'package:chat_app/chat/providers/chat_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ChatController {
  final ChatRepository repo;
  ChatController(this.repo);

  // final ChatRepository repo = ChatRepository(); // bad practice

  Stream<List<ChatRoom>> getAllRooms() => repo.getAllRooms();
  Stream<List<ChatMessage>> getMessages(String roomId) =>
      repo.getMessages(roomId);
  Stream<List<AppUser>> getAllUsers() => repo.getAllUsers();

  Future<String> openChatRoom(String otherUid) =>
      repo.createOrGetRoom(otherUid);

  Future<void> sendMessage({required String roomId, required String text}) =>
      repo.sendMessage(roomId: roomId, text: text);

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  Future<String> createGroupRoom({
    required List<String> memberUids,
    required String groupName,
  }) {
    if (!memberUids.contains(currentUserId)) {
      memberUids.add(currentUserId);
    }

    return repo.createGroupRoom(memberUids, groupName);
  }

  Future<void> updateGroupImage({required String roomId, required File file}) {
    return repo.updateGroupImage(roomId: roomId, file: file);
  }

  Stream<ChatRoom> getRoom(String roomId) {
    return repo.getRoomStream(roomId);
  }

  Future<void> clearChatWithUser(String otherUid) async {
    final roomId = await repo.createOrGetRoom(otherUid);
    await repo.clearChat(roomId);
  }

  Future<void> addMembersToGroup({
    required String roomId,
    required List<String> memberUids,
  }) {
    return repo.addMembersToGroup(roomId: roomId, newMemberUids: memberUids);
  }

  Future<void> updateGroupName({
    required String roomId,
    required String newName,
  }) {
    return repo.updateGroupName(roomId: roomId, newName: newName);
  }

  // 🗑 Delete single message
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    await repo.deleteMessage(roomId: roomId, messageId: messageId);
  }

  Future<void> sendMediaMessage({
    required String roomId,
    required File file,
    required bool isVideo,
    String? text,
  }) {
    return repo.sendMediaMessage(
      roomId: roomId,
      file: file,
      isVideo: isVideo,
      text: text,
    );
  }

  // ✏ Edit single message
  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) async {
    await repo.editMessage(
      roomId: roomId,
      messageId: messageId,
      newText: newText,
    );
  }

  // 🗑 Delete for everyone
  Future<void> deleteMessageForEveryone({
    required String roomId,
    required String messageId,
  }) {
    return repo.deleteMessageForEveryone(roomId: roomId, messageId: messageId);
  }

  // 🗑 Delete for me
  Future<void> deleteMessageForMe({
    required String roomId,
    required String messageId,
  }) {
    return repo.deleteMessageForMe(
      roomId: roomId,
      messageId: messageId,
      uid: currentUserId,
    );
  }

  Future<void> markMessageSeen({
    required String roomId,
    required String messageId,
  }) {
    return repo.markMessageSeen(
      roomId: roomId,
      messageId: messageId,
      uid: currentUserId,
    );
  }

  // 🚪 Exit group
  Future<void> exitGroup(String roomId) {
    return repo.exitGroup(roomId: roomId, uid: currentUserId);
  }
}
