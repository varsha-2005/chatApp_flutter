import 'package:chat_app/call/models/call_model.dart';
import 'package:chat_app/call/providers/call_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// 1. Provider Definition
final callControllerProvider = Provider((ref) {
  final callRepository = ref.read(callRepositoryProvider);
  return CallController(callRepository: callRepository);
});

class CallController {
  final CallRepository callRepository;

  CallController({
    required this.callRepository,
  });

  /// This function saves the call details to Firestore so it appears in the history.
  Future<void> saveCallHistory({
    required String callId,
    required String receiverId,
    required String receiverName,
    required String receiverPic,
    required String callerId,
    required String callerName,
    required String callerPic,
    required bool isVideo,
  }) async {
    // Create the model
    final call = CallModel(
      callId: callId,
      callerId: callerId,
      callerName: callerName,
      callerPic: callerPic,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverPic: receiverPic,
      callStatus: 'dialing', 
      isVideo: isVideo,
      timestamp: DateTime.now(),
    );

    // Save to Firestore
    await callRepository.makeCall(call);
  }

  /// Stream of call history
  Stream<List<CallModel>> getCallHistory() {
    return callRepository.getCallHistory();
  }
}