import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/screens/home/home_screen.dart';
import 'package:meetra_meet/screens/discover/discover_screen.dart';
import 'package:meetra_meet/screens/chat/chat_screens.dart';
import 'package:meetra_meet/screens/profile/profile_screen.dart';
import 'package:meetra_meet/screens/clan/create_clan_screen.dart';
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
    const Center(child: Text('Create Clan')), 
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateClanScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        child: Icon(Icons.add_rounded, size: 32.w),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          elevation: 0,
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.grid_view_rounded, 'Feed'),
              _buildNavItem(1, Icons.explore_rounded, 'Explore'),
              SizedBox(width: 48.w), // Space for FAB
              _buildNavItem(3, Icons.chat_bubble_outline_rounded, 'Chat'),
              _buildNavItem(4, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 24.w,
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
