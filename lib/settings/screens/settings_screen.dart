import 'dart:io';
import 'package:chat_app/auth/models/user_model.dart';
import 'package:chat_app/auth/providers/auth_controller.dart';
import 'package:chat_app/auth/screens/signup_screen.dart';
import 'package:chat_app/auth/widgets/bottom_navigation.dart';
import 'package:chat_app/settings/providers/settings.providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final userSettingsAsync = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        // 👇 logout button on top-right
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider).logout();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Error loading profile")),

        data: (user) {
          return userSettingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text("Error loading settings")),
            data: (settings) {
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  // PROFILE
                  ListTile(
                    onTap: () async {
                      // still change name when tile tapped
                      final newName = await _showInputDialog(
                        context,
                        "Change Name",
                        user.name,
                      );
                      if (newName != null && newName.isNotEmpty) {
                        await ref
                            .read(settingsRepositoryProvider)
                            .updateName(newName);
                      }
                    },
                    leading: GestureDetector(
                      // 👇 tap on profile picture → upload new image
                      onTap: () async {
                        await _pickAndUploadImage(context, ref);
                      },
                      child: CircleAvatar(
                        radius: 26,
                        backgroundImage: _buildProfileImage(user.image),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      "Tap name to edit, tap photo to change picture",
                    ),
                    // 👇 Edit + Delete buttons on the right
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await _showPhotoOptions(context, ref, user);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // delete current profile image
                            await ref
                                .read(settingsRepositoryProvider)
                                .updateProfileImage('');
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 30),

                  // CHANGE PASSWORD
                  _settingsTile(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () async {
                      final newPass = await _showInputDialog(
                        context,
                        "New Password",
                        "",
                      );
                      if (newPass != null && newPass.isNotEmpty) {
                        try {
                          await ref
                              .read(settingsRepositoryProvider)
                              .changePassword(newPass);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password updated successfully"),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.toString()}")),
                          );
                        }
                      }
                    },
                  ),

                  // READ CHATS TOGGLE
                  SwitchListTile(
                    activeColor: Colors.blueAccent,
                    value: settings.readChats,
                    onChanged: (value) {
                      ref
                          .read(settingsRepositoryProvider)
                          .upadteReadChats(value);
                    },
                    title: const Text(
                      "Read Chats",
                      style: TextStyle(fontSize: 16),
                    ),
                    secondary: const Icon(Icons.mark_chat_read_outlined),
                  ),

                  // DARK MODE TOGGLE
                  SwitchListTile(
                    activeColor: Colors.blueAccent,
                    value: settings.darkMode,
                    onChanged: (value) {
                      ref
                          .read(settingsRepositoryProvider)
                          .upadteDarkMode(value);
                      ref.read(themeModeProvider.notifier).state = value;
                    },
                    title: const Text(
                      "Dark Mode",
                      style: TextStyle(fontSize: 16),
                    ),
                    secondary: const Icon(Icons.dark_mode),
                  ),

                  const Divider(height: 30),

                  // ABOUT
                  _settingsTile(
                    icon: Icons.info_outline,
                    title: "About",
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: "My App",
                      applicationVersion: "1.0.0",
                      children: [const Text("This is a demo app.")],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),

      // ----------------- BOTTOM NAVIGATION -----------------
      bottomNavigationBar: const BottomNavigation(
        selectedIndex: 3,
      ), // 4 = Settings tab
    );
  }

  // Build correct image provider (supports asset or network)
  ImageProvider _buildProfileImage(String image) {
    if (image.isNotEmpty && image.startsWith('http')) {
      return NetworkImage(image);
    } else {
      // fallback to local asset
      return const AssetImage('assets/google_logo.png');
    }
  }

  // Pick image from gallery and upload
  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      await ref
          .read(settingsRepositoryProvider)
          .uploadAndSetProfileImage(File(picked.path));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated")),
        );
      }
    }
  }

  // Show options: change photo / remove photo (on edit button)
  Future<void> _showPhotoOptions(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Change photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndUploadImage(context, ref);
                },
              ),
              if (user.image.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Remove photo"),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref
                        .read(settingsRepositoryProvider)
                        .updateProfileImage('');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Reusable tile
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  // Simple input dialog
  Future<String?> _showInputDialog(
    BuildContext context,
    String title,
    String initial,
  ) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: title.contains("Password"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
