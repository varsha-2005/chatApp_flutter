import 'package:chat_app/settings/providers/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final userProfileProvider = StreamProvider((ref){
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchUserProfile();
});

final userSettingsProvider = StreamProvider((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchUserSettings();
});

final themeModeProvider = StateProvider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  return settings?.darkMode ?? false;  
});