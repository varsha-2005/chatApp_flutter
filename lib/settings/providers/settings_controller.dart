import 'package:chat_app/settings/providers/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsControllerProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});
