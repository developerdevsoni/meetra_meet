import 'package:cloud_firestore/cloud_firestore.dart';

class ClanMediaModel {
  final String id;
  final String clanId;
  final String url;
  final String type; // 'image' or 'video'
  final String uploadedBy;
  final DateTime createdAt;

  ClanMediaModel({
    required this.id,
    required this.clanId,
    required this.url,
    required this.type,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory ClanMediaModel.fromMap(Map<String, dynamic> map, String id) {
    return ClanMediaModel(
      id: id,
      clanId: map['clanId'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? 'image',
      uploadedBy: map['uploadedBy'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clanId': clanId,
      'url': url,
      'type': type,
      'uploadedBy': uploadedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
