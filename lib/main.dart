import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meetra_meet/screens/splash_screen.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:meetra_meet/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool firebaseInitialized = false;
  try {
    // This will fail if config files are missing
    await Firebase.initializeApp();
    firebaseInitialized = true;
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  runApp(MyApp(isFirebaseEnabled: firebaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool isFirebaseEnabled;
  
  const MyApp({super.key, required this.isFirebaseEnabled});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'ClanPulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: SplashScreen(isFirebaseEnabled: isFirebaseEnabled),
      ),
    );
  }
}
