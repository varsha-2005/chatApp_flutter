import 'package:chat_app/auth/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF25D366),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Communities",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
          SizedBox(height: 25),

          Text(
            "Stay connected with a community",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 10),

          // 📄 Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Communities bring members together in topic-based groups. "
              "Any community you're added to will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),

          SizedBox(height: 10),

          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "See example communities",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),

          const SizedBox(height: 50),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "New Community",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
    );
  }
}
