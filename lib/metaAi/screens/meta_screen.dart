import 'package:chat_app/metaAi/models/meta_ai_message.dart';
import 'package:chat_app/metaAi/providers/meta_ai_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MetaAIScreen extends ConsumerStatefulWidget {
  const MetaAIScreen({super.key});

  @override
  ConsumerState<MetaAIScreen> createState() => _MetaAIScreenState();
}

class _MetaAIScreenState extends ConsumerState<MetaAIScreen> {
  final TextEditingController _msgController = TextEditingController();
  bool _isSending = false;

  Future<void> _handleSend(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await ref.read(metaAIControllerProvider.notifier).sendMessage(text);
      _msgController.clear();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(metaAIControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Meta AI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
            onPressed: () {
              ref.read(metaAIControllerProvider.notifier).clearChat();
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 🌀 Banner + Suggestions + Messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 🌐 Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Meet Meta AI",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Ask anything — instant answers, ideas, and more.",
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Try asking:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                _aiSuggestion("Write a funny birthday message 🎂"),
                _aiSuggestion("Suggest me movie ideas 🍿"),
                _aiSuggestion("Explain quantum physics simply 🔬"),
                _aiSuggestion("Create a fitness plan 💪"),

                const SizedBox(height: 25),

                // ---------- CHAT MESSAGES ----------
                ...messages.map((msg) => _chatBubble(msg)).toList(),
                const SizedBox(height: 12),
              ],
            ),
          ),

          _buildMessageBox(),
        ],
      ),
    );
  }

  // 🟡 Suggestions — CLICK TO SEND
  Widget _aiSuggestion(String text) {
    return GestureDetector(
      onTap: () => _handleSend(text),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, style: const TextStyle(fontSize: 15)),
        ),
      ),
    );
  }

  // 💬 Chat bubbles UI
  Widget _chatBubble(MetaAIMessage msg) {
    final isUser = msg.isUser;

    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  // 📨 Message box
  Widget _buildMessageBox() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgController,
                decoration: InputDecoration(
                  hintText: "Message Meta AI...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _handleSend, // ENTER to send
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: _isSending ? Colors.grey : Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _isSending
                    ? null
                    : () => _handleSend(_msgController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
