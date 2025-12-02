import 'package:chat_app/auth/widgets/chat_base_layout.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseChatLayout(
      selectedChip: "Favourites",
      content: ListView(
        children: [
          _chatTile("Jenny ❤️", "You reacted 😍", "16:14", "assets/user1.png"),
          _chatTile("Mom ❤️", "Mom is typing…", "18:05", "assets/user2.png"),
        ],
      ),
    );
  }
}

Widget _chatTile(String name, String msg, String time, String image) {
  return ListTile(
    leading: CircleAvatar(
      radius: 24,
      backgroundImage: AssetImage(image),
    ),
    title: Text(
      name,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text(
      msg,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Text(
      time,
      style: const TextStyle(color: Colors.grey),
    ),
  );
}
