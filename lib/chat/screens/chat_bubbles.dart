import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: isMe
              ? const Radius.circular(12)
              : const Radius.circular(0),
          bottomRight: isMe
              ? const Radius.circular(0)
              : const Radius.circular(12),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class ChatImageBubble extends StatelessWidget {
  final String url;
  final String time;
  final bool isMe;

  const ChatImageBubble({
    super.key,
    required this.url,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              url,
              width: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class ChatVideoBubble extends StatefulWidget {
  final String url;
  final String time;
  final bool isMe;

  const ChatVideoBubble({
    super.key,
    required this.url,
    required this.isMe,
    required this.time,
  });

  @override
  State<ChatVideoBubble> createState() => _ChatVideoBubbleState();
}

class _ChatVideoBubbleState extends State<ChatVideoBubble> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _initialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized || _controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isMe ? const Color(0xFFDCF8C6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: widget.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          _initialized && _controller != null
              ? GestureDetector(
                  onTap: _togglePlay,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                      if (!_controller!.value.isPlaying)
                        const Icon(
                          Icons.play_circle_fill,
                          size: 50,
                          color: Colors.white70,
                        ),
                    ],
                  ),
                )
              : const SizedBox(
                  height: 150,
                  width: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
          const SizedBox(height: 4),
          Text(
            widget.time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
