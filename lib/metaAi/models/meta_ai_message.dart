// lib/metaAi/models/meta_ai_message.dart

class MetaAIMessage {
  final String sender;   // "user" or "ai"
  final String text;
  final DateTime timestamp;

  MetaAIMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  bool get isUser => sender == 'user';
}
