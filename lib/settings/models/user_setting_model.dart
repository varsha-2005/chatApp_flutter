class UserSetting {
  final bool readChats;
  final bool darkMode;

  UserSetting({required this.readChats, this.darkMode = false});

  factory UserSetting.fromMap(Map<String, dynamic> data) {
    return UserSetting(
      readChats: data['readChats'] ?? true,
      darkMode: data['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'readChats': readChats, 'darkMode': darkMode};
  }
}
