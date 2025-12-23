import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectMembersScreen extends ConsumerStatefulWidget {
  final bool isAddMembers;
  final String? existingGroupName;

  const SelectMembersScreen({
    super.key,
    this.isAddMembers = false,
    this.existingGroupName,
  });

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

    final currentUser = FirebaseAuth.instance.currentUser!;
    selectedMembers.add(currentUser.uid);

    if (widget.isAddMembers && widget.existingGroupName != null) {
      groupNameController.text = widget.existingGroupName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatController = ref.watch(chatControllerProvider);
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAddMembers ? "Add Members" : "Select Members",
        ),
      ),
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
                      enabled: !widget.isAddMembers,
                      decoration: InputDecoration(
                        labelText: "Group Name",
                        border: const OutlineInputBorder(),
                        filled: widget.isAddMembers,
                        fillColor: widget.isAddMembers
                            ? Colors.grey.shade200
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (widget.isAddMembers) {
                          Navigator.pop(
                            context,
                            selectedMembers.toList(),
                          );
                          return;
                        }

                        final groupName =
                            groupNameController.text.trim();

                        if (groupName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Please enter a group name"),
                            ),
                          );
                          return;
                        }

                        if (selectedMembers.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Select at least one member"),
                            ),
                          );
                          return;
                        }

                        final roomId =
                            await chatController.createGroupRoom(
                          memberUids: selectedMembers.toList(),
                          groupName: groupName,
                        );

                        Navigator.pop(context, roomId);
                      },
                      child: Text(
                        widget.isAddMembers
                            ? "Add Members"
                            : "Create Group",
                      ),
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
