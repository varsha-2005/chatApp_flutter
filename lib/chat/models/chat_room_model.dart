class ChatRoom {
  final String roomId;        // unique id (user1_user2 for personal, random for group)
  final List<String> members; // list of user UIDs
  final bool isGroup;         // true → group chat
  final String? groupName;    // optional (only for groups)
  final String? groupImage;   // optional (group dp)
  final DateTime createdAt;

  ChatRoom({
    required this.roomId,
    required this.members,
    required this.isGroup,
    this.groupName,
    this.groupImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'members': members,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupImage': groupImage,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> firebaseData) {
    return ChatRoom(
      roomId: firebaseData['roomId'],
      members: List<String>.from(firebaseData['members']),
      isGroup: firebaseData['isGroup'],
      groupName: firebaseData['groupName'],
      groupImage: firebaseData['groupImage'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(firebaseData['createdAt']),
    );
  }
}


// toMap => Converts ChatRoom instance to a Map for Firestore storage...like converting object to dictionary(key-value pairs)
// fromMap => Creates ChatRoom instance from Firestore data...like converting dictionary(key-value pairs) back to object