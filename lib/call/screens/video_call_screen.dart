import 'package:chat_app/call/models/call_model.dart';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatelessWidget {
  final CallModel call;

  const VideoCallScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Video Call")),
      body: Center(
        child: Text(
          "Video Call with ${call.callerId}",
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
