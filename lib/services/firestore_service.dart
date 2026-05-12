import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/event_model.dart';
import 'package:meetra_meet/models/message_model.dart';
import 'package:meetra_meet/models/clan_media_model.dart';
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
      await db.collection('clans').doc(clan.id).set(clan.toMap());
      // Automatically add creator to joinedClans
      await db.collection('users').doc(clan.adminId).update({
        'joinedClans': FieldValue.arrayUnion([clan.id])
      });
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  Future<void> joinClan(String userId, String clanId) async {
    final db = _db;
    if (db == null) return;
    try {
      // 1. Add clanId to user's joinedClans
      await db.collection('users').doc(userId).update({
        'joinedClans': FieldValue.arrayUnion([clanId])
      });
      // 2. Increment clan memberCount
      await db.collection('clans').doc(clanId).update({
        'memberCount': FieldValue.increment(1)
      });
    } catch (e) {
      print('Firestore join clan error: $e');
    }
  }

  Stream<List<ClanModel>> getMyClans(String userId) {
    final db = _db;
    if (db == null) return Stream.value([]);
    
    // We can't easily query by array content in a simple way if it's large,
    // but for joinedClans list it's usually fine to use where('joinedClans', arrayContains: clanId).
    // Actually, we want clans WHERE clanId is IN user's joinedClans.
    // So we first need the user's joinedClans list.
    
    return db.collection('users').doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return [];
      List<dynamic> clanIds = userDoc.data()?['joinedClans'] ?? [];
      if (clanIds.isEmpty) return [];
      
      // Firestore 'whereIn' supports up to 10-30 IDs usually.
      final clanSnapshots = await db.collection('clans')
          .where(FieldPath.documentId, whereIn: clanIds.take(10).toList())
          .get();
          
      return clanSnapshots.docs.map((doc) => ClanModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ClanModel>> getClansByLocation(String city) {
    final db = _db;
    if (db == null) return Stream.value([]);
    
    Query query = db.collection('clans');
    // if (city.isNotEmpty) {
    //   query = query.where('city', isEqualTo: city);
    // }
    
    return query.snapshots().map((snapshot) =>
            snapshot.docs.map((doc) => ClanModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

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

  Future<List<UserModel>> getClanMembers(String clanId) async {
    final db = _db;
    if (db == null) return [];
    try {
      final snapshot = await db
          .collection('users')
          .where('joinedClans', arrayContains: clanId)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Firestore get members error: $e');
      return [];
    }
  }

  Future<List<ClanMediaModel>> getClanMedia(String clanId) async {
    final db = _db;
    if (db == null) return [];
    try {
      final snapshot = await db
          .collection('clan_media')
          .where('clanId', isEqualTo: clanId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => ClanMediaModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Firestore get media error: $e');
      return [];
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
