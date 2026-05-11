import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/event_model.dart';
import 'package:meetra_meet/models/message_model.dart';

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
      await db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Firestore error: $e');
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
  Stream<List<ClanModel>> getClans() {
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

  Future<void> joinClan(String userId, String clanId) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.collection('users').doc(userId).update({
        'joinedClans': FieldValue.arrayUnion([clanId])
      });
      await db.collection('clans').doc(clanId).update({
        'memberCount': FieldValue.increment(1)
      });
    } catch (e) {
      print('Firestore error: $e');
    }
  }

  // Event Operations
  Stream<List<EventModel>> getEvents() {
    final db = _db;
    if (db == null) return Stream.value([]);
    try {
      return db.collection('events').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => EventModel.fromMap(doc.data(), doc.id)).toList());
    } catch (e) {
      print('Firestore error: $e');
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
