import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/screens/onboarding_screen.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.05; // Slightly faster for better UX
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/images/splash_bg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Dark Overlay with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0D1B1E).withOpacity(0),
                  const Color(0xFF0D1B1E).withOpacity(0),
                  const Color(0xFF0D1B1E),
                ],
              ),
            ),
          ),
          // Content
          // Center(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       // Custom M Logo (using an icon as a placeholder for now, or the logo asset)
          //       Icon(Icons.diversity_3_rounded, color: const Color(0xFF4FBFA5), size: 100.w),
          //       SizedBox(height: 16.h),
          //       Text(
          //         'meetra',
          //         style: GoogleFonts.outfit(
          //           fontSize: 56.sp,
          //           fontWeight: FontWeight.bold,
          //           letterSpacing: -2,
          //           color: Colors.white,
          //         ),
          //       ),
          //       Text(
          //         'FIND YOUR PEOPLE',
          //         style: GoogleFonts.plusJakartaSans(
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w800,
          //           letterSpacing: 4,
          //           color: const Color(0xFF4FBFA5),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Bottom Progress & Text
          Positioned(
            bottom: 60.h,
            left: 40.w,
            right: 40.w,
            child: Column(
              children: [
                // Custom Progress Bar
                Container(
                  height: 4.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FBFA5),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Building real connections...',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
