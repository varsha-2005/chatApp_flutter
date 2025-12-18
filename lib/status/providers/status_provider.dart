import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'status_repository.dart';
import 'status_controller.dart';
import '../models/status_model.dart';

final statusRepositoryProvider = Provider<StatusRepository>((ref) {
  return StatusRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

final statusControllerProvider =
    StateNotifierProvider<StatusController, bool>((ref) {
  final repo = ref.watch(statusRepositoryProvider);
  return StatusController(repo);
});

final statusStreamProvider =
    StreamProvider<List<StatusModel>>((ref) {
  final controller = ref.watch(statusControllerProvider.notifier);
  return controller.statusesStream;
});
