import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/screens/main_navigation.dart';
import 'package:meetra_meet/screens/onboarding_screen.dart';
import 'package:meetra_meet/screens/splash_screen.dart';
import 'package:meetra_meet/services/auth_service.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:meetra_meet/firebase_options.dart';
import 'package:app_links/app_links.dart';
import 'package:meetra_meet/screens/clan/clan_detail_screen.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // For web, you MUST provide options. Run 'flutterfire configure' to generate firebase_options.dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path.contains('/clan') || uri.host == 'clan') {
      final clanId = uri.queryParameters['id'];
      if (clanId != null) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => FutureBuilder(
              future: FirestoreService().getAllClans().first, // Simplest way to get the clan object
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final clan = snapshot.data!.firstWhere((c) => c.id == clanId);
                  return ClanDetailScreen(clan: clan);
                }
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 13/14 design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: authService),
            RepositoryProvider.value(value: firestoreService),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => AuthBloc(authService: authService)),
              BlocProvider(create: (context) => ClanBloc(firestoreService: firestoreService)),
            ],
            child: MaterialApp(
              title: 'Meetra-Meet',
              navigatorKey: _navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              home: const AuthWrapper(),
            ),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print(state);
        if (state is AuthAuthenticated) {
          return const MainNavigation();
        } else if (state is AuthUnauthenticated) {
          return const OnboardingScreen();
        }
        return const SplashScreen();
      },
    );
  }
}
