import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Using the version-specific singleton if standard constructor fails
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Auth state stream
  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Sign in with Google (Reverted to the API version that works in your environment)
  Future<UserModel?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // WEB LOGIN
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        userCredential =
        await _auth.signInWithPopup(googleProvider);
      } else {
        // MOBILE LOGIN
        await _googleSignIn.initialize(
          serverClientId:
          "522991060175-67ps4663nivam8ekha7doi37nr7b7r6e.apps.googleusercontent.com",
        );

        final GoogleSignInAccount googleUser =
        await _googleSignIn.authenticate();

        final googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential =
        await _auth.signInWithCredential(credential);
      }

      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        UserModel? userModel =
        await _firestoreService.getUser(firebaseUser.uid);

        if (userModel == null) {
          userModel = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Anonymous',
            email: firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL,
            joinedClans: [],
            ownedClans: [],
            createdAt: DateTime.now(),
          );

          await _firestoreService.createUser(userModel);
        } else {

          await _firestoreService.updateFcmToken(firebaseUser.uid);
        }

        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', firebaseUser.uid);

        return userModel;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }

    return null;
  }
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google SignOut error: $e');
    }
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_id');
  }

  Future<UserModel?> getCurrentUserModel() async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return await _firestoreService.getUser(firebaseUser.uid);
    }
    return null;
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', credential.user!.uid);
        return await _firestoreService.getUser(credential.user!.uid);
      }
    } catch (e) {
      print('Email sign in error: $e');
      rethrow;
    }
    return null;
  }

  Future<UserModel?> signUpWithEmail(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        final userModel = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          joinedClans: [],
          ownedClans: [],
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(userModel);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', credential.user!.uid);

        return userModel;
      }
    } catch (e) {
      print('Email sign up error: $e');
      rethrow;
    }
    return null;
  }
}
