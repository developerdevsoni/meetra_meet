import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String clanId;
  final double? latitude;
  final double? longitude;
  final List<String> participants;
  final List<String> attendees; // Added for live attendance
  final bool isPremium;
  final DateTime createdAt;

  var plannerId;

  var location;

  var eventDate;

  var imageUrl;
  final bool isPaid;
  final String fees;
  final String ageLimit;
  final String plannerContact;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.clanId,
    required this.plannerId,
    required this.location,
    this.latitude,
    this.longitude,
    required this.eventDate,
    required this.imageUrl,
    required this.participants,
    this.attendees = const [],
    required this.isPremium,
    required this.createdAt,
    this.isPaid = false,
    this.fees = '',
    this.ageLimit = '',
    this.plannerContact = '',
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      clanId: map['clanId'] ?? '',
      plannerId: map['plannerId'] ?? '',
      location: map['location'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      eventDate: map['eventDate'] != null 
          ? (map['eventDate'] as Timestamp).toDate() 
          : DateTime.now(),
      imageUrl: map['imageUrl'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      attendees: List<String>.from(map['attendees'] ?? []),
      isPremium: map['isPremium'] ?? false,
      isPaid: map['isPaid'] ?? false,
      fees: map['fees'] ?? '',
      ageLimit: map['ageLimit'] ?? '',
      plannerContact: map['plannerContact'] ?? '',
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
      'latitude': latitude,
      'longitude': longitude,
      'eventDate': Timestamp.fromDate(eventDate),
      'imageUrl': imageUrl,
      'participants': participants,
      'attendees': attendees,
      'isPremium': isPremium,
      'isPaid': isPaid,
      'fees': fees,
      'ageLimit': ageLimit,
      'plannerContact': plannerContact,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
