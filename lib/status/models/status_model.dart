import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String id;
  final String uid;          // owner user id
  final String userName;
  final String userImage;
  final String mediaUrl;     // image or video URL (empty for text-only)
  final bool isVideo;
  final String? text;        // ✅ new: text status content
  final DateTime timestamp;
  final List<String> viewedBy; // list of userIds who saw this status

  StatusModel({
    required this.id,
    required this.uid,
    required this.userName,
    required this.userImage,
    required this.mediaUrl,
    required this.isVideo,
    required this.timestamp,
    required this.viewedBy,
    this.text,               // ✅ optional
  });

  bool get isExpired =>
      timestamp.isBefore(DateTime.now().subtract(const Duration(hours: 24)));

  bool isViewedBy(String userId) => viewedBy.contains(userId);

  factory StatusModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return StatusModel(
      id: doc.id,
      uid: data['uid'] as String,
      userName: data['userName'] as String,
      userImage: data['userImage'] as String,
      mediaUrl: (data['mediaUrl'] ?? '') as String,
      isVideo: data['isVideo'] ?? false,
      text: data['text'] as String?,                          // ✅ new
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      viewedBy: List<String>.from(data['viewedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'userImage': userImage,
      'mediaUrl': mediaUrl,
      'isVideo': isVideo,
      'text': text,                                    // ✅ new
      'timestamp': Timestamp.fromDate(timestamp),
      'viewedBy': viewedBy,
    };
  }
}
