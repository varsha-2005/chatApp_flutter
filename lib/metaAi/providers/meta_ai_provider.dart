// lib/metaAi/providers/meta_ai_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'meta_ai_controller.dart';
import 'meta_ai_repository.dart';
import '../models/meta_ai_message.dart';

/// Provides a single MetaAIRepository instance
final metaAIRepositoryProvider = Provider<MetaAIRepository>((ref) {
  return MetaAIRepository();
});

/// Provides the MetaAIController and exposes List<MetaAIMessage> as state
final metaAIControllerProvider =
    StateNotifierProvider<MetaAIController, List<MetaAIMessage>>((ref) {
  final repo = ref.watch(metaAIRepositoryProvider);
  return MetaAIController(repo);
});
