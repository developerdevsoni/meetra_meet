import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/screens/home/home_screen.dart';
import 'package:meetra_meet/screens/discover/discover_screen.dart';
import 'package:meetra_meet/screens/chat/chat_screens.dart';
import 'package:meetra_meet/screens/profile/profile_screen.dart';
import 'package:meetra_meet/screens/clan/create_clan_screen.dart';
import 'package:meetra_meet/screens/event/event_screen.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:animations/animations.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const EventScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildFloatingDock(),
    );
  }

  Widget _buildFloatingDock() {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      height: 60.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35.r),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Stack(
        children: [
          // Glass Background
          ClipRRect(
            borderRadius: BorderRadius.circular(35.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(35.r),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Nav Items
          Padding(

            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Row(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
                _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined),
                _buildCenterAddButton(),
                _buildNavItem(2, Icons.event_available_rounded, Icons.event_note_outlined),
                _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateClanScreen()),
        );
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 28.w),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(12.w),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color:isSelected? AppColors.primary
            : Colors.grey.shade500,
          size: 26.w,
        ),
      ),
    );
  }
}