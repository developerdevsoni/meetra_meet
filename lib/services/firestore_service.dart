import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/event_model.dart';
import 'package:meetra_meet/models/message_model.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // User Operations
  Future<void> createUser(UserModel user) async {
    final db = _db;
    if (db == null) return;
    try {
      // Get FCM Token
      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        print('FCM Token error: $e');
      }

      final userData = user.toMap();
      if (token != null) userData['fcmToken'] = token;

      await db.collection('users').doc(user.id).set(userData);
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  Future<void> updateFcmToken(String userId) async {
    final db = _db;
    if (db == null) return;
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await db.collection('users').doc(userId).update({'fcmToken': token});
      }
    } catch (e) {
      print('Firestore update FCM error: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    final db = _db;
    if (db == null) return null;
    try {
      final doc = await db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Firestore error: $e');
    }
    return null;
  }

  // Clan Operations
  Future<void> createClan(ClanModel clan) async {
    final db = _db;
    if (db == null) return;
    try {
      // Use the clan.id which should be a UUID now
      await db.collection('clans').doc(clan.id).set(clan.toMap());
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  Stream<List<ClanModel>> getClansByLocation(String city) {
    final db = _db;
    if (db == null) return Stream.value([]);
    
    Query query = db.collection('clans');
    // if (city.isNotEmpty) {
    //   query = query.where('city');
    // }
    
    return query.snapshots().map((snapshot) =>
            snapshot.docs.map((doc) => ClanModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Stream<List<ClanModel>> getAllClans() {
    final db = _db;
    if (db == null) return Stream.value([]);
    try {
      return db.collection('clans').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => ClanModel.fromMap(doc.data(), doc.id)).toList());
    } catch (e) {
      print('Firestore error: $e');
      return Stream.value([]);
    }
  }

  // Event Operations
  Future<void> createEvent(EventModel event) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.collection('events').doc(event.id).set(event.toMap());
      // Logic for push notification would go here (typically a Cloud Function)
    } catch (e) {
      print('Firestore create event error: $e');
    }
  }

  Stream<List<EventModel>> getClanEvents(String clanId) {
    final db = _db;
    if (db == null) return Stream.value([]);
    try {
      return db
          .collection('events')
          .where('clanId', isEqualTo: clanId)
          .orderBy('eventDate')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => EventModel.fromMap(doc.data(), doc.id)).toList());
    } catch (e) {
      print('Firestore get events error: $e');
      return Stream.value([]);
    }
  }

  // Chat Operations
  Stream<List<MessageModel>> getMessages(String chatId) {
    final db = _db;
    if (db == null) return Stream.value([]);
    try {
      return db
          .collection('messages')
          .doc(chatId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList());
    } catch (e) {
      print('Firestore error: $e');
      return Stream.value([]);
    }
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    final db = _db;
    if (db == null) return;
    try {
      await db
          .collection('messages')
          .doc(chatId)
          .collection('chats')
          .add(message.toMap());
    } catch (e) {
      print('Firestore error: $e');
    }
  }
}
