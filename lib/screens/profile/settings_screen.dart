import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/screens/onboarding_screen.dart';
import 'package:meetra_meet/screens/profile/edit_profile_screen.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    UserModel? user;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Account'),
            _buildMenuItem(
              Icons.person_outline_rounded, 
              'Account Profile',
              onTap: () {
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfileScreen(user: user!)),
                  );
                }
              },
            ),
            _buildMenuItem(Icons.notifications_none_rounded, 'Notifications', 
              onTap: () => _showComingSoon(context, 'Notifications')),
            
            SizedBox(height: 24.h),
            _buildSectionTitle('Preferences'),
            _buildMenuItem(Icons.settings_outlined, 'General Settings',
              onTap: () => _showComingSoon(context, 'General Settings')),
            _buildMenuItem(Icons.shield_outlined, 'Privacy & Safety',
              onTap: () => _showComingSoon(context, 'Privacy & Safety')),
            
            SizedBox(height: 24.h),
            _buildSectionTitle('Support'),
            _buildMenuItem(Icons.help_center_outlined, 'Help Center',
              onTap: () => _showComingSoon(context, 'Help Center')),
            _buildMenuItem(Icons.info_outline_rounded, 'About Meetra',
              onTap: () => _showComingSoon(context, 'About Meetra')),
            
            SizedBox(height: 40.h),
            _buildLogoutButton(context),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature settings coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.w),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton.icon(
        onPressed: () async {
          context.read<AuthBloc>().add((AuthLogoutRequested()));
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: const Text(
          'Logout Session',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
      ),
    );
  }
}
