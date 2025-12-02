import 'package:chat_app/auth/providers/auth_provider.dart';
import 'package:chat_app/call/providers/call_controller.dart';
import 'package:chat_app/chat/models/message_model.dart';
import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';

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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onMessageLongPress(ChatMessage msg, bool isMe) async {
    if (!isMe) return;

    final chatController = ref.read(chatControllerProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit message"),
                onTap: () async {
                  Navigator.pop(context);
                  final newText =
                      await _showEditMessageDialog(initialText: msg.message);
                  if (newText != null && newText.trim().isNotEmpty) {
                    await chatController.editMessage(
                      roomId: widget.roomId,
                      messageId: msg.id,
                      newText: newText.trim(),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete message"),
                onTap: () async {
                  Navigator.pop(context);
                  await chatController.deleteMessage(
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
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatStream =
        ref.watch(chatControllerProvider).getMessages(widget.roomId);

    final auth = ref.watch(authProvider);
    final currentUser = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
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

              ref.read(callControllerProvider).saveCallHistory(
                    callId: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
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

              ref.read(callControllerProvider).saveCallHistory(
                    callId: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
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
                    final isMe = msg.senderId ==
                        ref
                            .read(chatControllerProvider)
                            .currentUserId;

                    return GestureDetector(
                      onLongPress: () => _onMessageLongPress(msg, isMe),
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ChatBubble(
                          text: msg.message,
                          time: msg.timeSent
                              .toLocal()
                              .toString()
                              .substring(11, 16),
                          isMe: isMe,
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
                const Icon(Icons.add, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Message",
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
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

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft:
              isMe ? const Radius.circular(12) : const Radius.circular(0),
          bottomRight:
              isMe ? const Radius.circular(0) : const Radius.circular(12),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
