import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String clanId;
  final String plannerId; // Added as requested
  final String location;
  final DateTime eventDate;
  final String imageUrl;
  final List<String> participants;
  final bool isPremium;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.clanId,
    required this.plannerId,
    required this.location,
    required this.eventDate,
    required this.imageUrl,
    required this.participants,
    required this.isPremium,
    required this.createdAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      clanId: map['clanId'] ?? '',
      plannerId: map['plannerId'] ?? '',
      location: map['location'] ?? '',
      eventDate: map['eventDate'] != null 
          ? (map['eventDate'] as Timestamp).toDate() 
          : DateTime.now(),
      imageUrl: map['imageUrl'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      isPremium: map['isPremium'] ?? false,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'clanId': clanId,
      'plannerId': plannerId,
      'location': location,
      'eventDate': Timestamp.fromDate(eventDate),
      'imageUrl': imageUrl,
      'participants': participants,
      'isPremium': isPremium,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
