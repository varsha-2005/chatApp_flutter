import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';
import 'auth_controller.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authControllerProvider =
    Provider<AuthController>((ref) {
  return AuthController(
    ref.read(authRepositoryProvider),
  );
});
