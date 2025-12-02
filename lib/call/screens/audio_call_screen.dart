import 'package:chat_app/call/models/call_model.dart';
import 'package:flutter/material.dart';

class AudioCallScreen extends StatelessWidget {
  final CallModel call;

  const AudioCallScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Audio Call")),
      body: Center(
        child: Text(
          "Audio Call with ${call.callerId}",
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
