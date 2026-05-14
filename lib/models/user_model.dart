import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String? username;
  final String email;
  final String? bio;
  final int reputation;
  final String? phoneNumber;
  final String? photoUrl;
  final List<String> joinedClans;
  final List<String> ownedClans;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    this.bio,
    this.reputation = 0,
    this.phoneNumber,
    this.photoUrl,
    required this.joinedClans,
    required this.ownedClans,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      username: map['username'],
      email: map['email'] ?? '',
      bio: map['bio'],
      reputation: map['reputation'] ?? 0,
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoUrl'],
      joinedClans: List<String>.from(map['joinedClans'] ?? []),
      ownedClans: List<String>.from(map['ownedClans'] ?? []),
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'bio': bio,
      'reputation': reputation,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'joinedClans': joinedClans,
      'ownedClans': ownedClans,
      'fcmToken': fcmToken,
      'createdAt': createdAt,
    };
  }
}

