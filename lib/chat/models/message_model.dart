class ChatMessage {
  final String id;          // message id
  final String roomId;      // chat room id
  final String senderId;    // who sent the message
  final String message;     // text
  final String? imageUrl;   // image or video URL
  final bool isVideo;       // ✅ new: true if this is a video
  final DateTime timeSent;
  final bool isSeen;        // for personal chats
  final List<String>? seenBy; // for groups → list of user ids

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    this.imageUrl,
    required this.isVideo,          // ✅ required in constructor
    required this.timeSent,
    required this.isSeen,
    this.seenBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'message': message,
      'imageUrl': imageUrl,
      'isVideo': isVideo, // ✅ store media type
      'timeSent': timeSent.millisecondsSinceEpoch,
      'isSeen': isSeen,
      'seenBy': seenBy,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      roomId: map['roomId'],
      senderId: map['senderId'],
      message: map['message'],
      imageUrl: map['imageUrl'],
      isVideo: map['isVideo'] ?? false, 
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      isSeen: map['isSeen'] ?? false,
      seenBy:
          map['seenBy'] != null ? List<String>.from(map['seenBy']) : null,
    );
  }
}
