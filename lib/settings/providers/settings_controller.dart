// lib/settings/providers/settings_controller.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_setting_model.dart';
import '../../auth/models/user_model.dart';
import 'settings_repository.dart';

class SettingsController {
  final SettingsRepository _repo;

  SettingsController(this._repo);

  // STREAMS
  Stream<AppUser> watchUserProfile() {
    return _repo.watchUserProfile();
  }

  Stream<UserSetting> watchUserSettings() {
    return _repo.watchUserSettings();
  }

  // ACTIONS
  Future<void> updateName(String newName) {
    return _repo.updateName(newName);
  }

  Future<void> updateProfileImage(String imageUrl) {
    return _repo.updateProfileImage(imageUrl);
  }

  Future<String> uploadAndSetProfileImage(File file) {
    return _repo.uploadAndSetProfileImage(file);
  }

  Future<void> updateReadChats(bool value) {
    return _repo.upadteReadChats(value);
  }

  Future<void> updateDarkMode(bool value) {
    return _repo.upadteDarkMode(value);
  }

  Future<void> changePassword(String newPassword) {
    return _repo.changePassword(newPassword);
  }
}
