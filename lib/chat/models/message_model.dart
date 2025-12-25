class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;  
  final String message;
  final String? imageUrl;
  final bool isVideo;
  final DateTime timeSent;
  final bool isSeen;
  final List<String>? seenBy;
  final bool deletedForEveryone;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.imageUrl,
    required this.isVideo,
    required this.timeSent,
    required this.isSeen,
    this.seenBy,
    this.deletedForEveryone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'imageUrl': imageUrl,
      'isVideo': isVideo,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'isSeen': isSeen,
      'seenBy': seenBy,
      'deletedForEveryone': deletedForEveryone,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      roomId: map['roomId'],
      senderId: map['senderId'],
      senderName: map['senderName'] ?? 'Unknown',
      message: map['message'],
      imageUrl: map['imageUrl'],
      isVideo: map['isVideo'] ?? false,
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      isSeen: map['isSeen'] ?? false,
      seenBy: map['seenBy'] != null
          ? List<String>.from(map['seenBy'])
          : null,
      deletedForEveryone: map['deletedForEveryone'] ?? false,
    );
  }
}
