import 'package:flutter/material.dart';
import 'package:meetra_meet/screens/onboarding_screen.dart';
import 'package:meetra_meet/utils/theme.dart';

class SplashScreen extends StatefulWidget {
  final bool isFirebaseEnabled;
  
  const SplashScreen({super.key, required this.isFirebaseEnabled});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => OnboardingScreen(isFirebaseEnabled: widget.isFirebaseEnabled)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Clans',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'REAL WORLD CONNECTION',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (!widget.isFirebaseEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Running in UI Preview Mode (Firebase Disabled)',
                  style: TextStyle(color: Colors.orange[800], fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
