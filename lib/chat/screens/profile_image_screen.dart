import 'package:flutter/material.dart';

class ProfileImageScreen extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final String heroTag; // must match the Hero in the previous screen

  const ProfileImageScreen({
    super.key,
    required this.imageUrl,
    required this.userName,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imageUrl.startsWith("http");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(userName, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: isNetwork ? Image.network(imageUrl) : Image.asset(imageUrl),
          ),
        ),
      ),
    );
  }
}
