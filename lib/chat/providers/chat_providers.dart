import 'package:chat_app/chat/providers/chat_repository.dart';

import 'chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

final chatControllerProvider = Provider(
  (ref) => ChatController(ref.read(chatRepositoryProvider)),
);
