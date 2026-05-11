import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  // Sign in with Google (Reverted to the API version that works in your environment)
  Future<UserModel?> signInWithGoogle() async {
    try {
      // In version 7.x+, authenticate() is often used instead of signIn()

      await _googleSignIn.initialize(serverClientId: "522991060175-67ps4663nivam8ekha7doi37nr7b7r6e.apps.googleusercontent.com");
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Some versions of the 7.x API only expose idToken directly
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: null, // Set to null if the getter is missing in your version
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        UserModel? userModel = await _firestoreService.getUser(firebaseUser.uid);
        
        if (userModel == null) {
          userModel = UserModel(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Anonymous',
            email: firebaseUser.email ?? '',
            photoUrl: firebaseUser.photoURL,
            joinedClans: [],
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
}
