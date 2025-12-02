// lib/metaAi/providers/meta_ai_controller.dart
import 'package:flutter_riverpod/legacy.dart';

import '../models/meta_ai_message.dart';
import 'meta_ai_repository.dart';

class MetaAIController extends StateNotifier<List<MetaAIMessage>> {
  final MetaAIRepository _repository;

  MetaAIController(this._repository) : super(const []);

  /// Send a user message, then fetch and add AI reply
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // 1️⃣ Add user message
    final userMsg = MetaAIMessage(
      sender: 'user',
      text: trimmed,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    // 2️⃣ Ask repository for AI response
    final aiText = await _repository.getAIResponse(trimmed);

    // 3️⃣ Add AI message
    final aiMsg = MetaAIMessage(
      sender: 'ai',
      text: aiText,
      timestamp: DateTime.now(),
    );
    state = [...state, aiMsg];
  }

  void clearChat() {
    state = const [];
  }
}
