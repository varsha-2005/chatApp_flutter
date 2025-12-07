import 'package:chat_app/status/screens/update_screen.dart';
import 'package:chat_app/call/screens/call_screen.dart';
import 'package:chat_app/chat/screens/chat_screen.dart';
import 'package:chat_app/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';


class BottomNavigation extends StatelessWidget {
  final int selectedIndex;

  const BottomNavigation({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      elevation: 5,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const UpdatesScreen(), 
              ),
            );
            break;

          

          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
            break;

          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CallsScreen()),
            );
            break;

          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.update), label: "Updates"),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chats"),
        BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
