import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/services/firestore_service.dart';

class AuthService {
  // Use a private helper to safely access Firebase
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Safely return auth state changes
  Stream<User?> get user => _auth?.authStateChanges() ?? const Stream.empty();

  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      print('Firebase not initialized. Cannot sign in.');
      return null;
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(credential);
      
      // Update or create user in Firestore
      if (userCredential.user != null) {
        final existingUser = await _firestoreService.getUser(userCredential.user!.uid);
        if (existingUser == null) {
          final newUser = UserModel(
            id: userCredential.user!.uid,
            name: userCredential.user!.displayName ?? 'Anonymous',
            email: userCredential.user!.email ?? '',
            photoUrl: userCredential.user!.photoURL,
            joinedClans: [],
            createdAt: DateTime.now(),
          );
          await _firestoreService.createUser(newUser);
        }
      }
      
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth?.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
