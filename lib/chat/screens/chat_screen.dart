import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/auth/widgets/chat_base_layout.dart';
import 'package:chat_app/call/services/zego_service.dart';
import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:chat_app/chat/screens/chat_detail_screen.dart';
import 'package:chat_app/chat/screens/profile_image_screen.dart';
import 'package:chat_app/chat/screens/select_member.dart';
// import 'package:chat_app/profile/screens/profile_image_screen.dart'; // 👈 NEW
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser!;
      if (user != null) {
        ZegoService.initZego(
          userID: user.uid,
          userName: user.displayName ?? 'User',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatController = ref.watch(chatControllerProvider);
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      body: BaseChatLayout(
        selectedChip: "All",
        content: StreamBuilder<List<AppUser>>(
          stream: chatController.getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No users found"));
            }

            final users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                if (user.uid.isEmpty) return const SizedBox();

                return Dismissible(
                  key: ValueKey(user.uid),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Clear chat"),
                        content: Text(
                          "Delete all chat messages with ${user.name}? This will not remove the contact.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      await chatController.clearChatWithUser(user.uid);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Chat with ${user.name} cleared"),
                        ),
                      );
                    }

                    // return false to keep the tile (do not remove contact)
                    return false;
                  },
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileImageScreen(
                              imageUrl: user.image.isNotEmpty
                                  ? user.image
                                  : "assets/google_logo.png",
                              userName: user.name,
                              heroTag: "profile-${user.uid}",
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: "profile-${user.uid}",
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: user.image.isNotEmpty
                              ? (user.image.startsWith("http")
                                  ? NetworkImage(user.image)
                                  : AssetImage(user.image)
                                      as ImageProvider)
                              : const AssetImage("assets/google_logo.png"),
                        ),
                      ),
                    ),
                    title: Text(
                      user.uid == currentUser.uid
                          ? "${user.name} (You)"
                          : user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () async {
                      final roomId = await chatController.openChatRoom(
                        user.uid,
                      );

                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            roomId: roomId,
                            userName: user.uid == currentUser.uid
                                ? "${user.name} (You)"
                                : user.name,
                            userImage: user.image.isNotEmpty
                                ? user.image
                                : "assets/google_logo.png",
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SelectMembersScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
