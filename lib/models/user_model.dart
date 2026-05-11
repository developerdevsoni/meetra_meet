import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final List<String> joinedClans;
  final String? fcmToken; // Added for push notifications
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    required this.joinedClans,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoUrl'],
      joinedClans: List<String>.from(map['joinedClans'] ?? []),
      fcmToken: map['fcmToken'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'joinedClans': joinedClans,
      'fcmToken': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
