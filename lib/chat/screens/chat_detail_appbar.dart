import 'dart:io';
import 'package:chat_app/auth/providers/auth_provider.dart';
import 'package:chat_app/call/providers/call_controller.dart';
import 'package:chat_app/chat/models/chat_room_model.dart';
import 'package:chat_app/chat/providers/chat_providers.dart';
import 'package:chat_app/chat/screens/select_member.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ChatDetailAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String roomId;
  final String userName;
  final String userImage;

  const ChatDetailAppBar({
    super.key,
    required this.roomId,
    required this.userName,
    required this.userImage,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);
    final currentUser = authController.currentUser;
    final roomAsync = ref.watch(chatControllerProvider).getRoom(roomId);

    return AppBar(
      backgroundColor: const Color(0xFF128C7E),
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      title: StreamBuilder<ChatRoom>(
        stream: ref.watch(chatControllerProvider).getRoom(roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(userName);
          }

          final room = snapshot.data!;
          final isGroup = room.isGroup;

          final name = isGroup ? room.groupName ?? 'Group' : userName;
          final image = isGroup ? room.groupImage ?? '' : userImage;

          return Row(
            children: [
              GestureDetector(
                onTap: isGroup
                    ? () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked == null) return;

                        await ref
                            .read(chatControllerProvider)
                            .updateGroupImage(
                              roomId: roomId,
                              file: File(picked.path),
                            );
                      }
                    : null,
                child: CircleAvatar(
                  backgroundImage: image.isNotEmpty && image.startsWith('http')
                      ? NetworkImage(image)
                      : const AssetImage('assets/app_logo.png')
                            as ImageProvider,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isGroup
                    ? () async {
                        final controller = TextEditingController(text: name);

                        final newName = await showDialog<String>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Edit group name"),
                            content: TextField(controller: controller),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
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

                        if (newName != null && newName.isNotEmpty) {
                          await ref
                              .read(chatControllerProvider)
                              .updateGroupName(
                                roomId: roomId,
                                newName: newName,
                              );
                        }
                      }
                    : null,
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),

      actions: [
        ZegoSendCallInvitationButton(
          isVideoCall: false,
          resourceID: "zego_call",
          invitees: [ZegoUIKitUser(id: roomId, name: userName)],
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
                  receiverId: roomId,
                  receiverName: userName,
                  receiverPic: userImage,
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
          invitees: [ZegoUIKitUser(id: roomId, name: userName)],
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
                  receiverId: roomId,
                  receiverName: userName,
                  receiverPic: userImage,
                  callerId: currentUser.uid,
                  callerName: currentUser.displayName ?? "Me",
                  callerPic: currentUser.photoURL ?? "",
                  isVideo: true,
                );
          },
        ),

        StreamBuilder<ChatRoom>(
          stream: ref.watch(chatControllerProvider).getRoom(roomId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.isGroup) {
              return const SizedBox.shrink();
            }

            final room = snapshot.data!;

            return PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'add_members') {
                  final selected = await Navigator.push<List<String>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectMembersScreen(
                        isAddMembers: true,
                        existingGroupName: room.groupName,
                      ),
                    ),
                  );

                  if (selected != null && selected.isNotEmpty) {
                    await ref
                        .read(chatControllerProvider)
                        .addMembersToGroup(
                          roomId: roomId,
                          memberUids: selected,
                        );
                  }
                }

                if (value == 'exit_group') {
                  await ref.read(chatControllerProvider).exitGroup(roomId);
                  Navigator.pop(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'add_members', child: Text('Add members')),
                PopupMenuItem(
                  value: 'exit_group',
                  child: Text(
                    'Exit Group',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
