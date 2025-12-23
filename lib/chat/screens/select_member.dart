import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/auth/providers/auth_provider.dart';
import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SelectMembersScreen extends ConsumerStatefulWidget {
  const SelectMembersScreen({super.key});

  @override
  ConsumerState<SelectMembersScreen> createState() =>
      _SelectMembersScreenState();
}

class _SelectMembersScreenState extends ConsumerState<SelectMembersScreen> {
  final Set<String> selectedMembers = {}; 
  final TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authController = ref.watch(authControllerProvider);
    final currentUser = authController.currentUser!;
    selectedMembers.add(currentUser.uid); 
  }

  @override
  Widget build(BuildContext context) {
    final chatController = ref.watch(chatControllerProvider);
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Select Members")),
      body: StreamBuilder<List<AppUser>>(
        stream: chatController.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return CheckboxListTile(
                      title: Text(
                        user.uid == currentUser.uid
                            ? "${user.name} (You)"
                            : user.name,
                      ),
                      subtitle: Text(user.email),
                      value: selectedMembers.contains(user.uid),
                      onChanged: (isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            selectedMembers.add(user.uid);
                          } else {
                            selectedMembers.remove(user.uid);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: groupNameController,
                      decoration: const InputDecoration(
                        labelText: "Group Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final groupName = groupNameController.text.trim();
                        if (groupName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a group name"),
                            ),
                          );
                          return;
                        }

                        if (selectedMembers.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Select at least one member"),
                            ),
                          );
                          return;
                        }

                        // Create group room
                        final roomId = await chatController.createGroupRoom(
                          memberUids: selectedMembers.toList(),
                          groupName: groupName,
                        );

                        Navigator.pop(context, roomId); // return roomId if needed
                      },
                      child: const Text("Create Group"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }
}
