import 'dart:io';
import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/auth/widgets/bottom_navigation.dart';
import 'package:chat_app/status/providers/status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/status_model.dart';
import 'status_view_screen.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  Future<void> _pickAndUploadStatus(
    BuildContext context,
    WidgetRef ref,
    AppUser currentUser,
  ) async {
    final picker = ImagePicker();

    // Bottom sheet to choose text / image / video
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text Status'),
                onTap: () => Navigator.pop(ctx, 'text'),
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Upload Image Status'),
                onTap: () => Navigator.pop(ctx, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Upload Video Status'),
                onTap: () => Navigator.pop(ctx, 'video'),
              ),
            ],
          ),
        );
      },
    );

    if (type == null) return;

    // 🔹 TEXT STATUS FLOW
    if (type == 'text') {
      final textController = TextEditingController();

      final text = await showDialog<String>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('New text status'),
            content: TextField(
              controller: textController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Type your status...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), // cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final value = textController.text.trim();
                  if (value.isEmpty) {
                    Navigator.pop(ctx); // don't upload empty status
                  } else {
                    Navigator.pop(ctx, value);
                  }
                },
                child: const Text('Post'),
              ),
            ],
          );
        },
      );

      if (text == null || text.isEmpty) return;

      await ref
          .read(statusControllerProvider.notifier)
          .uploadTextStatus(user: currentUser, text: text);

      return;
    }

    // 🔹 IMAGE / VIDEO FLOW (same as before)
    XFile? picked;
    bool isVideo = false;

    if (type == 'image') {
      picked = await picker.pickImage(source: ImageSource.gallery);
      isVideo = false;
    } else if (type == 'video') {
      picked = await picker.pickVideo(source: ImageSource.gallery);
      isVideo = true;
    }

    if (picked == null) return;

    final file = File(picked.path);

    await ref
        .read(statusControllerProvider.notifier)
        .uploadStatus(user: currentUser, file: file, isVideo: isVideo);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) Get current user from Firestore using uid
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!userSnap.hasData || !userSnap.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User not found')),
          );
        }

        final currentUser =
            AppUser.fromMap(userSnap.data!.data()!); // now we have AppUser

        // 2) Now use your status providers as before
        final asyncStatuses = ref.watch(statusStreamProvider);
        final isLoading = ref.watch(statusControllerProvider);

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: const Text(
              "Updates",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          body: Stack(
            children: [
              asyncStatuses.when(
                data: (statuses) {
                  final List<StatusModel> myStatuses =
                      statuses.where((s) => s.uid == currentUser.uid).toList();
                  final List<StatusModel> others =
                      statuses.where((s) => s.uid != currentUser.uid).toList();

                  // 🔹 Group others' statuses by user
                  final Map<String, List<StatusModel>> othersByUser = {};
                  for (final s in others) {
                    othersByUser.putIfAbsent(s.uid, () => []).add(s);
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ---------------- STATUS SECTION ----------------
                      const Text(
                        "Status",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // My Status Row
                      ListTile(
                        onTap: () {
                          if (myStatuses.isEmpty) {
                            _pickAndUploadStatus(
                              context,
                              ref,
                              currentUser,
                            );
                          } else {
                            // sort my statuses by time (oldest -> newest)
                            final userStatuses =
                                List<StatusModel>.from(myStatuses)
                                  ..sort((a, b) =>
                                      a.timestamp.compareTo(b.timestamp));

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StatusViewScreen(
                                  statuses: userStatuses,
                                  initialIndex: 0,
                                  currentUserId: currentUser.uid,
                                ),
                              ),
                            );
                          }
                        },
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundImage:
                                  NetworkImage(currentUser.image),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: const Text(
                          "My status",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          myStatuses.isEmpty
                              ? "Add to my status"
                              : "You have ${myStatuses.length} status",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.photo_camera_outlined),
                              onPressed: () => _pickAndUploadStatus(
                                  context, ref, currentUser),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _pickAndUploadStatus(
                                  context, ref, currentUser),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ---------------- RECENT UPDATES ----------------
                      const Text(
                        "Recent updates",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      if (others.isEmpty)
                        const Text(
                          "No recent status from contacts.",
                          style: TextStyle(color: Colors.black54),
                        )
                      else
                        ...othersByUser.entries.map(
                          (entry) {
                            final userStatuses = entry.value
                              ..sort((a, b) =>
                                  a.timestamp.compareTo(b.timestamp));
                            final latestStatus = userStatuses.last;

                            return _statusTile(
                              context: context,
                              statuses: userStatuses,
                              latestStatus: latestStatus,
                              currentUserId: currentUser.uid,
                            );
                          },
                        ),

                      const SizedBox(height: 20),

                      // ---------------- CHANNELS ----------------
                      const Text(
                        "Channels",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Stay updated on topics that matter to you. "
                        "Find channels to follow below.",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Explore more",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),

              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
        );
      },
    );
  }

  // Tile for other users' statuses
  Widget _statusTile({
    required BuildContext context,
    required List<StatusModel> statuses,
    required StatusModel latestStatus,
    required String currentUserId,
  }) {
    final viewed = latestStatus.viewedBy.contains(currentUserId);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusViewScreen(
              statuses: statuses,       // 👈 all statuses of that user
              initialIndex: 0,          // start from first
              currentUserId: currentUserId,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(latestStatus.userImage),
      ),
      title: Text(
        latestStatus.userName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        TimeOfDay.fromDateTime(latestStatus.timestamp).format(context),
      ),
      trailing: viewed
          ? const Icon(Icons.visibility, size: 18)
          : const Icon(Icons.fiber_new, size: 18, color: Colors.green),
    );
  }
}
