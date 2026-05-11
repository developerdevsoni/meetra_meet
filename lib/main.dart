import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        if (state is AuthAuthenticated) {
          return const MainNavigation();
        } else if (state is AuthUnauthenticated || state is AuthFailure) {
          return const OnboardingScreen();
        }
        // AuthInitial or AuthLoading
        return const SplashScreen();
      },
    );
  }
}
