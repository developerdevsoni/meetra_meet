import 'package:cloud_firestore/cloud_firestore.dart';

class ClanModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String adminId;
  final String adminName;
  final int memberCount;
  final int totalEvents;
  final bool isPremium;
  final List<String> categories;
  final String city;
  final String state;
  final String country;
  final DateTime createdAt;

  ClanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.adminId,
    required this.adminName,
    required this.memberCount,
    required this.totalEvents,
    required this.isPremium,
    required this.categories,
    required this.city,
    required this.state,
    required this.country,
    required this.createdAt,
  });

  factory ClanModel.fromMap(Map<String, dynamic> map, String id) {
    return ClanModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      adminId: map['adminId'] ?? '',
      adminName: map['adminName'] ?? '',
      memberCount: map['memberCount'] ?? 0,
      totalEvents: map['totalEvents'] ?? 0,
      isPremium: map['isPremium'] ?? false,
      categories: List<String>.from(map['categories'] ?? []),
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'adminId': adminId,
      'adminName': adminName,
      'memberCount': memberCount,
      'totalEvents': totalEvents,
      'isPremium': isPremium,
      'categories': categories,
      'city': city,
      'state': state,
      'country': country,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
