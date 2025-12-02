import 'dart:io';

import 'package:chat_app/auth/models/user_model.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/status_model.dart';
import 'status_repository.dart';

class StatusController extends StateNotifier<bool> {
  final StatusRepository _repository;

  StatusController(this._repository) : super(false);

  bool get isLoading => state;

  Stream<List<StatusModel>> get statusesStream =>
      _repository.getStatusesStream();

  Future<void> uploadStatus({
    required AppUser user,
    required File file,
    required bool isVideo,
  }) async {
    try {
      state = true;
      await _repository.uploadStatus(user: user, file: file, isVideo: isVideo);
    } finally {
      state = false;
    }
  }

  // ✅ NEW: text-only status
  Future<void> uploadTextStatus({
    required AppUser user,
    required String text,
  }) async {
    try {
      state = true;
      await _repository.uploadTextStatus(user: user, text: text);
    } finally {
      state = false;
    }
  }

  Future<void> markViewed({
    required String statusId,
    required String viewerUid,
  }) {
    return _repository.markStatusViewed(
      statusId: statusId,
      viewerUid: viewerUid,
    );
  }

  Future<void> cleanExpiredStatuses() {
    return _repository.deleteExpiredStatuses();
  }
}
