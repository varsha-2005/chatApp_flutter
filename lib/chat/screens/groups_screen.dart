import 'package:chat_app/auth/widgets/chat_base_layout.dart';
import 'package:chat_app/chat/models/chat_room_model.dart';
import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:chat_app/chat/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';


class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatController = ref.watch(chatControllerProvider);
    final currentUser = FirebaseAuth.instance.currentUser!;

    return BaseChatLayout(
      selectedChip: "Groups",
      content: StreamBuilder<List<ChatRoom>>(
        stream: chatController.getAllRooms(), // Get all rooms
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No groups found"));
          }

          final groups = snapshot.data!
              .where((room) => room.isGroup) // Only groups
              .toList();

          if (groups.isEmpty) {
            return const Center(child: Text("No groups found"));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        roomId: group.roomId,
                        userName: group.groupName ?? "Group",
                        userImage: "assets/group_icon.png", // default group icon
                      ),
                    ),
                  );
                },
                leading: const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage("assets/group_icon.png"),
                ),
                title: Text(
                  group.groupName ?? "Unnamed Group",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${group.members.length} members",
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  group.createdAt != null
                      ? "${group.createdAt!.hour.toString().padLeft(2, '0')}:${group.createdAt!.minute.toString().padLeft(2, '0')}"
                      : "",
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
