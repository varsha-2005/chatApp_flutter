import 'package:chat_app/chat/models/message_model.dart';
import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:chat_app/chat/screens/image_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_bubbles.dart';

class ChatMessageList extends ConsumerWidget {
  final String roomId;
  final bool isGroup;

  const ChatMessageList({
    super.key,
    required this.roomId,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid =
        ref.read(chatControllerProvider).currentUserId;

    return StreamBuilder<List<ChatMessage>>(
      stream: ref.watch(chatControllerProvider).getMessages(roomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!;
        if (messages.isEmpty) {
          return const Center(child: Text("No messages yet"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderId == currentUid;

            /// MARK MESSAGE AS SEEN
            if (!isMe &&
                !(msg.seenBy?.contains(currentUid) ?? false)) {
              ref.read(chatControllerProvider).markMessageSeen(
                    roomId: roomId,
                    messageId: msg.id,
                  );
            }

            final seenCount = msg.seenBy?.length ?? 0;

            /// ✅ CORRECT SEEN LOGIC (ONLY CHANGE)
            final isSeenByAll = isGroup
                ? seenCount >= 2 // all group members seen (current backend)
                : seenCount >= 1; // 1–1 chat

            final timeStr =
                msg.timeSent.toLocal().toString().substring(11, 16);

            return GestureDetector(
              onLongPress: () {
                _showMessageActions(context, ref, msg, isMe);
              },
              child: Align(
                alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    /// 👤 SENDER NAME (GROUP ONLY)
                    if (!isMe && isGroup)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          msg.senderId,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                    /// 🖼 IMAGE MESSAGE
                    if (msg.imageUrl != null &&
                        msg.imageUrl!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImagePreviewScreen(
                                imageUrl: msg.imageUrl!,
                              ),
                            ),
                          );
                        },
                        child: ChatImageBubble(
                          url: msg.imageUrl!,
                          isMe: isMe,
                          time: timeStr,
                          isSeen: isSeenByAll,
                        ),
                      ),

                    /// 💬 TEXT MESSAGE
                    if (msg.message.isNotEmpty)
                      ChatBubble(
                        text: msg.message,
                        time: timeStr,
                        isMe: isMe,
                        isSeen: isSeenByAll,
                      ),

                    /// 👁️ SEEN COUNT (GROUP ONLY)
                    if (isMe && isGroup && !isSeenByAll)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Seen by $seenCount',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ===============================
/// MESSAGE ACTIONS
/// ===============================
void _showMessageActions(
  BuildContext context,
  WidgetRef ref,
  ChatMessage msg,
  bool isMe,
) {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Wrap(
          children: [
            if (isMe)
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit message"),
                onTap: () async {
                  Navigator.pop(context);

                  final controller =
                      TextEditingController(text: msg.message);

                  final newText = await showDialog<String>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Edit message"),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(
                            context,
                            controller.text.trim(),
                          ),
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                  );

                  if (newText != null && newText.isNotEmpty) {
                    await ref
                        .read(chatControllerProvider)
                        .editMessage(
                          roomId: msg.roomId,
                          messageId: msg.id,
                          newText: newText,
                        );
                  }
                },
              ),

            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text("Delete for everyone"),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(chatControllerProvider)
                      .deleteMessageForEveryone(
                        roomId: msg.roomId,
                        messageId: msg.id,
                      );
                },
              ),

            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete for me"),
              onTap: () async {
                Navigator.pop(context);
                await ref
                    .read(chatControllerProvider)
                    .deleteMessageForMe(
                      roomId: msg.roomId,
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
