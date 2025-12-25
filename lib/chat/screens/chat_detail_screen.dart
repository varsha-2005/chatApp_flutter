import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_detail_appbar.dart';
import 'chat_message_list.dart';
import 'chat_input_bar.dart';
import '../providers/chat_providers.dart';
import '../models/chat_room_model.dart';

class ChatDetailScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<ChatRoom>(
      stream: ref.watch(chatControllerProvider).getRoom(roomId),
      builder: (context, snapshot) {
        final isGroup = snapshot.data?.isGroup ?? false;

        return Scaffold(
          appBar: ChatDetailAppBar(
            roomId: roomId,
            userName: userName,
            userImage: userImage,
          ),
          body: Column(
            children: [
              Expanded(
                child: ChatMessageList(
                  roomId: roomId,
                  isGroup: isGroup, 
                ),
              ),
              ChatInputBar(roomId: roomId),
            ],
          ),
        );
      },
    );
  }
}
