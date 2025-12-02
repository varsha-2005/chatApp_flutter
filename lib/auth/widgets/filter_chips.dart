import 'package:chat_app/auth/screens/favorite_screen.dart';
import 'package:chat_app/chat/screens/chat_screen.dart';
import 'package:chat_app/chat/screens/groups_screen.dart';
import 'package:chat_app/chat/screens/unread_screen.dart';
import 'package:flutter/material.dart';


class FilterChips extends StatelessWidget {
  final String selectedChip;

  const FilterChips({super.key, required this.selectedChip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          _chip(context, "All"),
          const SizedBox(width: 10),
          _chip(context, "Unread"),
          const SizedBox(width: 10),
          _chip(context, "Favourites"),
          const SizedBox(width: 10),
          _chip(context, "Groups"),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String name) {
    final bool selected = name == selectedChip;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        switch (name) {
          case "All":
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
            break;

          case "Unread":
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UnreadScreen()),
            );
            break;

          case "Favourites":
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const FavoriteScreen()),
            );
            break;

          case "Groups":
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GroupsScreen()),
            );
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDCF8C6) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: selected ? const Color(0xFF075E54) : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
