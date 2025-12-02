import 'package:cloud_firestore/cloud_firestore.dart';
class AppUser{
  final String uid;
  final String name;
  final String email;
  final String image;
  final DateTime? lastSeen;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    this.lastSeen,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      image: data['image'],
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'image': image,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }
}