import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetra_meet/screens/auth/auth_screens.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Find your\npeople',
      'description': 'Discover clans and communities that match your interests and vibe.',
      'image': 'assets/images/onboarding_1.png',
      'badge': '1/3',
    },
    {
      'title': 'Attend\nreal events',
      'description': 'Join exciting meetups and events happening around you.',
      'image': 'assets/images/onboarding_2.png',
      'badge': '2/3',
    },
    {
      'title': 'Build\nyour clan',
      'description': 'Create your own clan and bring like-minded people together.',
      'image': 'assets/images/onboarding_3.png',
      'badge': '3/3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _onboardingData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Images (Transitions)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _onboardingData[index]['image']!,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [

                          Colors.white,
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.3),
                          Colors.white,
                        ],
                        stops: const [0.29, 0.4, 0.7,.9],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: Text('Skip', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Progress Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _onboardingData[_currentPage]['badge']!,
                      style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Text Content
                  Text(
                    _onboardingData[_currentPage]['title']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _onboardingData[_currentPage]['description']!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  // Floating Glass Cards based on page
                  _buildFloatingCard(_currentPage),
                  SizedBox(height: 40.h),
                  // Bottom Actions
                  _buildBottomBar(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCard(int page) {
    switch (page) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // Center(
            // //   child: Lottie.asset(
            // //     'assets/lottie/hiking.json',
            // //     height: 250.h,
            // //     repeat: true,
            // //   ),
            // // ),
            // SizedBox(height: 20.h),
            GlassContainer(
              height: 100.h,
              width: 200.w,
              blur: 10,
              color: Colors.white.withOpacity(0.2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.3)],
              ),
              borderRadius: BorderRadius.circular(24.r),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    _buildAvatarStack(),
                    SizedBox(width: 12.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('20K+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        Text('Active Members', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10.sp)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 1:
        return GlassContainer(
          height: 90.h,
          width: 220.w,
          blur: 10,
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.event_available_rounded, color: Colors.white, size: 24.w),
                ),
                SizedBox(width: 12.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    Text('Get update on event', style: TextStyle(color: AppColors.primary, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      case 2:
        return GlassContainer(
          height: 90.h,
          width: 190.w,
          blur: 10,
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(color: const Color(0xFF1F8A70), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.verified_user_rounded, color: Colors.white, size: 24.w),
                ),
                SizedBox(width: 12.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Safe & Verified', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    Text('Trusted Community', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10.sp)),
                  ],
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 60.w,
      child: Stack(
        children: [
          CircleAvatar(radius: 12.r, backgroundImage: const NetworkImage('https://i.pravatar.cc/100?u=1')),
          Positioned(left: 15.w, child: CircleAvatar(radius: 12.r, backgroundImage: const NetworkImage('https://i.pravatar.cc/100?u=2'))),
          Positioned(left: 30.w, child: CircleAvatar(radius: 12.r, backgroundImage: const NetworkImage('https://i.pravatar.cc/100?u=3'))),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Page Indicators
        Row(
          children: List.generate(
            _onboardingData.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 8.w),
              height: 8.r,
              width: index == _currentPage ? 24.w : 8.r,
              decoration: BoxDecoration(
                color: index == _currentPage ? AppColors.primary : AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        // Navigation Button
        _currentPage == 2
            ? Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Get Started', style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8.w),
                              const Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13.sp),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
                },
                child: Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ),
              ),
      ],
    );
  }
}
