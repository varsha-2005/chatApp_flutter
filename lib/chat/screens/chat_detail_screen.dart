import 'package:chat_app/auth/providers/auth_provider.dart';
import 'package:chat_app/call/providers/call_controller.dart';
import 'package:chat_app/chat/models/message_model.dart';
import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'chat_bubbles.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String userName;
  final String userImage;

  const ChatDetailScreen({
    super.key,
    required this.roomId,
    required this.userName,
    required this.userImage,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  void sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatController = ref.read(chatControllerProvider);
    await chatController.sendMessage(roomId: widget.roomId, text: text);

    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _pickAndSendMedia() async {
    final chatController = ref.read(chatControllerProvider);

    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Send Image'),
                onTap: () => Navigator.pop(ctx, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Send Video'),
                onTap: () => Navigator.pop(ctx, 'video'),
              ),
            ],
          ),
        );
      },
    );

    if (type == null) return;

    XFile? picked;
    bool isVideo = false;

    if (type == 'image') {
      picked = await _picker.pickImage(source: ImageSource.gallery);
      isVideo = false;
    } else if (type == 'video') {
      picked = await _picker.pickVideo(source: ImageSource.gallery);
      isVideo = true;
    }

    if (picked == null) return;

    final file = File(picked.path);

    await chatController.sendMediaMessage(
      roomId: widget.roomId,
      file: file,
      isVideo: isVideo,
      text: null,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onMessageLongPress(ChatMessage msg, bool isMe) async {
    final chatController = ref.read(chatControllerProvider);
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // ✏ Edit (only sender)
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text("Edit message"),
                  onTap: () async {
                    Navigator.pop(context);
                    final newText = await _showEditMessageDialog(
                      initialText: msg.message,
                    );
                    if (newText != null && newText.trim().isNotEmpty) {
                      await chatController.editMessage(
                        roomId: widget.roomId,
                        messageId: msg.id,
                        newText: newText.trim(),
                      );
                    }
                  },
                ),

              // 🗑 Delete for everyone (only sender)
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text("Delete for everyone"),
                  onTap: () async {
                    Navigator.pop(context);
                    await chatController.deleteMessageForEveryone(
                      roomId: widget.roomId,
                      messageId: msg.id,
                    );
                  },
                ),

              // 🗑 Delete for me (anyone)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete for me"),
                onTap: () async {
                  Navigator.pop(context);
                  await chatController.deleteMessageForMe(
                    roomId: widget.roomId,
                    messageId: msg.id,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showEditMessageDialog({required String initialText}) async {
    final controller = TextEditingController(text: initialText);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit message"),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatStream = ref
        .watch(chatControllerProvider)
        .getMessages(widget.roomId);

    final authController = ref.watch(authControllerProvider);
    final currentUser = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF128C7E),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.userImage.startsWith("http")
                  ? NetworkImage(widget.userImage)
                  : AssetImage(widget.userImage) as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          ZegoSendCallInvitationButton(
            isVideoCall: false,
            resourceID: "zego_call",
            invitees: [ZegoUIKitUser(id: widget.roomId, name: widget.userName)],
            icon: ButtonIcon(
              icon: const Icon(Icons.call, color: Colors.white),
              backgroundColor: Colors.transparent,
            ),
            iconSize: const Size(40, 40),
            buttonSize: const Size(40, 40),
            onPressed: (code, message, p2) {
              if (code.isNotEmpty || currentUser == null) return;

              ref
                  .read(callControllerProvider)
                  .saveCallHistory(
                    callId: DateTime.now().millisecondsSinceEpoch.toString(),
                    receiverId: widget.roomId,
                    receiverName: widget.userName,
                    receiverPic: widget.userImage,
                    callerId: currentUser.uid,
                    callerName: currentUser.displayName ?? "Me",
                    callerPic: currentUser.photoURL ?? "",
                    isVideo: false,
                  );
            },
          ),
          ZegoSendCallInvitationButton(
            isVideoCall: true,
            resourceID: "zego_call",
            invitees: [ZegoUIKitUser(id: widget.roomId, name: widget.userName)],
            icon: ButtonIcon(
              icon: const Icon(Icons.videocam, color: Colors.white),
              backgroundColor: Colors.transparent,
            ),
            iconSize: const Size(40, 40),
            buttonSize: const Size(40, 40),
            onPressed: (code, message, p2) {
              if (code.isNotEmpty || currentUser == null) return;

              ref
                  .read(callControllerProvider)
                  .saveCallHistory(
                    callId: DateTime.now().millisecondsSinceEpoch.toString(),
                    receiverId: widget.roomId,
                    receiverName: widget.userName,
                    receiverPic: widget.userImage,
                    callerId: currentUser.uid,
                    callerName: currentUser.displayName ?? "Me",
                    callerPic: currentUser.photoURL ?? "",
                    isVideo: true,
                  );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'exit_group') {
                await ref.read(chatControllerProvider).exitGroup(widget.roomId);

                if (!mounted) return;
                Navigator.pop(context); // exit chat screen
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'exit_group',
                child: Text('Exit Group', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),

          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: chatStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe =
                        msg.senderId ==
                        ref.read(chatControllerProvider).currentUserId;

                    final timeStr = msg.timeSent.toLocal().toString().substring(
                      11,
                      16,
                    );

                    return GestureDetector(
                      onLongPress: () => _onMessageLongPress(msg, isMe),
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (msg.imageUrl != null &&
                                msg.imageUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: msg.isVideo
                                    ? ChatVideoBubble(
                                        url: msg.imageUrl!,
                                        isMe: isMe,
                                        time: timeStr, // ⏰ time for video
                                      )
                                    : ChatImageBubble(
                                        url: msg.imageUrl!,
                                        isMe: isMe,
                                        time: timeStr, // ⏰ time for image
                                      ),
                              ),
                            if (msg.message.isNotEmpty)
                              ChatBubble(
                                text: msg.message,
                                time: timeStr,
                                isMe: isMe,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickAndSendMedia,
                  child: const Icon(Icons.add, color: Colors.grey),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Message",
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: sendMessage,
                  child: const CircleAvatar(
                    backgroundColor: Color(0xFF128C7E),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
