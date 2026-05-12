import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/blocs/clan/clan_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/screens/clan/clan_admin_screen.dart';
import 'package:meetra_meet/screens/clan/clan_detail_screen.dart';
import 'package:meetra_meet/screens/onboarding_screen.dart';
import 'package:meetra_meet/services/auth_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final user = state.user;

          return BlocBuilder<ClanBloc, ClanState>(
            builder: (context, clanState) {
              List<ClanModel> myClans = [];
              if (clanState is ClanLoaded) {
                myClans = clanState.myClans;
              }

              return CustomScrollView(
                slivers: [
                  _buildHeader(context, user.displayName, user.photoURL),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (myClans.isNotEmpty) ...[
                            _buildMyClanSection(context, user.uid, myClans),
                            SizedBox(height: 32.h),
                          ],
                          Text(
                            'Account Settings',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildProfileMenu(context),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? name, String? photoUrl) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(top: 80.h, bottom: 40.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.r)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60.r,
              backgroundColor: Colors.white,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? Icon(Icons.person, size: 60.r, color: AppColors.primary) : null,
            ),
            SizedBox(height: 20.h),
            Text(
              name??"",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Tribal Explorer',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String clanCount) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(clanCount, 'Clans'),
          _buildDivider(),
          _buildStatItem('3', 'Events'),
          _buildDivider(),
          _buildStatItem('120', 'XP'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 30.h, width: 1, color: AppColors.surfaceContainerHigh);
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 20.sp)),
        Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildMyClanSection(BuildContext context, String userId, List<ClanModel> myClans) {
    // Separate clans where user is admin
    final managedClans = myClans.where((c) => c.adminId == userId).toList();
    final joinedClans = myClans.where((c) => c.adminId != userId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Clans',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${myClans.length} Total',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (managedClans.isNotEmpty) ...[
          Text(
            'Managed by You',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ...managedClans.map((clan) => _buildClanCard(context, clan, true)),
          SizedBox(height: 16.h),
        ],
        if (joinedClans.isNotEmpty) ...[
          Text(
            'Joined Tribes',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ...joinedClans.map((clan) => _buildClanCard(context, clan, false)),
        ],
      ],
    );
  }

  Widget _buildClanCard(BuildContext context, ClanModel clan, bool isAdmin) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12.w),
        leading: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: DecorationImage(
              image: NetworkImage(clan.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          clan.name,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${clan.memberCount} Members • ${clan.city}',
          style: TextStyle(fontSize: 12.sp),
        ),
        trailing: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isAdmin ? AppColors.primaryContainer : AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            isAdmin ? Icons.settings_rounded : Icons.chevron_right_rounded,
            color: isAdmin ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 20.w,
          ),
        ),
        onTap: () {
          if (isAdmin) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ClanAdminScreen(clan: clan)),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ClanDetailScreen(clan: clan)),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(Icons.person_outline_rounded, 'Account Profile'),
        _buildMenuItem(Icons.settings_outlined, 'Preferences'),
        _buildMenuItem(Icons.shield_outlined, 'Privacy & Safety'),
        _buildMenuItem(Icons.help_center_outlined, 'Support'),
        SizedBox(height: 24.h),
        _buildLogoutButton(context),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, color: AppColors.primary, size: 20.w),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
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
        label: const Text('Logout Session', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
      ),
    );
  }
}
