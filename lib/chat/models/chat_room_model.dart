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

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      roomId: map['roomId'],
      members: List<String>.from(map['members']),
      isGroup: map['isGroup'],
      groupName: map['groupName'],
      groupImage: map['groupImage'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}
