import 'dart:io';

import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  final String roomId;
  const ChatInputBar({super.key, required this.roomId});

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAndSendMedia,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Message",
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isEmpty) return;

              ref
                  .read(chatControllerProvider)
                  .sendMessage(
                    roomId: widget.roomId,
                    text: _controller.text.trim(),
                  );
              _controller.clear();
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFF128C7E),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndSendMedia() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    await ref
        .read(chatControllerProvider)
        .sendMediaMessage(
          roomId: widget.roomId,
          file: File(picked.path),
          isVideo: false,
        );
  }
}
