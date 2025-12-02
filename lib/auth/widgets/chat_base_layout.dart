import 'package:chat_app/auth/screens/favorite_screen.dart';
import 'package:chat_app/metaAi/screens/meta_screen.dart';
import 'package:chat_app/auth/widgets/bottom_navigation.dart';
import 'package:chat_app/chat/screens/chat_screen.dart';
import 'package:chat_app/chat/screens/groups_screen.dart';
import 'package:chat_app/chat/screens/unread_screen.dart';
import 'package:flutter/material.dart';


class BaseChatLayout extends StatelessWidget {
  final Widget content;
  final String selectedChip;

  const BaseChatLayout({
    super.key,
    required this.content,
    required this.selectedChip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------ TOP BAR ---------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.more_horiz, size: 28),
                  Row(
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 28),
                      SizedBox(width: 18),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF25D366),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ------------ TITLE ---------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                "Chats",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            // ------------ SEARCH BAR ---------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MetaAIScreen()),
                  );
                },
                child: IgnorePointer(
                  // prevents keyboard from opening
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF2F2F2),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Ask Meta AI or Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ------------ FILTER CHIPS ---------------
            FilterChips(selectedChip: selectedChip),

            const SizedBox(height: 10),

            // ------------- ARCHIVED BOX ---------------
            ListTile(
              leading: Icon(Icons.archive_outlined, color: Colors.grey),
              title: Text(
                "Archived",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const Divider(height: 1),

            // *********** PAGE CONTENT HERE ***********
            Expanded(child: content),
          ],
        ),
      ),

      // ---------- BOTTOM NAVIGATION ----------
      bottomNavigationBar: BottomNavigation(selectedIndex: 2),
    );
  }
}

class FilterChips extends StatelessWidget {
  final String selectedChip;
  const FilterChips({required this.selectedChip});

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
          color: selected ? Color(0xFFDCF8C6) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: selected ? Color(0xFF075E54) : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
