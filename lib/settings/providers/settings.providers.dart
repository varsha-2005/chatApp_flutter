// lib/settings/providers/settings_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user_setting_model.dart';
import '../../auth/models/user_model.dart';
import 'settings_repository.dart';
import 'settings_controller.dart';

// REPOSITORY PROVIDER (same idea as chatRepositoryProvider)
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// CONTROLLER PROVIDER (same idea as chatControllerProvider)
final settingsControllerProvider = Provider<SettingsController>((ref) {
  final repo = ref.read(settingsRepositoryProvider);
  return SettingsController(repo);
});

// STREAM: USER PROFILE
final userProfileProvider = StreamProvider<AppUser>((ref) {
  return ref.read(settingsControllerProvider).watchUserProfile();
});

// STREAM: USER SETTINGS
final userSettingsProvider = StreamProvider<UserSetting>((ref) {
  return ref.read(settingsControllerProvider).watchUserSettings();
});

// THEME STATE (unchanged logic)
final themeModeProvider = StateProvider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider).value;
  return settings?.darkMode ?? false;
});
