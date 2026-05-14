import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/blocs/clan/clan_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/screens/clan/clan_admin_screen.dart';
import 'package:meetra_meet/screens/clan/clan_detail_screen.dart';
import 'package:meetra_meet/screens/profile/edit_profile_screen.dart';
import 'package:meetra_meet/screens/profile/settings_screen.dart';
import 'package:meetra_meet/utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //
      //   title: Column(
      //
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         'My Profile',
      //         style: GoogleFonts.plusJakartaSans(
      //           fontSize: 24.sp,
      //           fontWeight: FontWeight.bold,
      //           color: AppColors.onSurface,
      //         ),
      //       ),
      //       Text(
      //         'Your tribe, your journey',
      //         style: GoogleFonts.plusJakartaSans(
      //           fontSize: 14.sp,
      //           color: AppColors.onSurfaceVariant,
      //         ),
      //       ),
      //     ],
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Container(
      //         padding: EdgeInsets.all(8.w),
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           shape: BoxShape.circle,
      //           boxShadow: [
      //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
      //           ],
      //         ),
      //         child: Icon(Icons.ios_share_rounded, size: 20.w, color: AppColors.onSurface),
      //       ),
      //       onPressed: () {},
      //     ),
      //     IconButton(
      //       icon: Container(
      //         padding: EdgeInsets.all(8.w),
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           shape: BoxShape.circle,
      //           boxShadow: [
      //             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
      //           ],
      //         ),
      //         child: Icon(Icons.settings_outlined, size: 20.w, color: AppColors.onSurface),
      //       ),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => const SettingsScreen()),
      //         );
      //       },
      //     ),
      //     SizedBox(width: 8.w),
      //   ],
      // ),
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

              final ownedClans = myClans.where((c) => c.adminId == user.id).toList();
              final joinedClans = myClans.where((c) => c.adminId != user.id).toList();

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    _buildHeader(context, user),
                    SizedBox(height: 5.h),
                    _buildProfileHeader(context, user),
                    // SizedBox(height: 24.h),

                    SizedBox(height: 24.h),
                    _buildStatsRow(joinedClans.length, ownedClans.length, user.reputation),
                    SizedBox(height: 24.h),
                    _buildActionButtons(context, user),
                    SizedBox(height: 32.h),
                    _buildClanTabs(ownedClans, joinedClans, user.id),
                    SizedBox(height: 100.h),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical:  10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null ? Icon(Icons.person, size: 50.r, color: AppColors.primary) : null,
                  ),
                  Positioned(
                    bottom: 5.r,
                    right: 5.r,
                    child: Container(
                      width: 15.r,
                      height: 15.r,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.king_bed_outlined, size: 12.w, color: AppColors.primary),
                              SizedBox(width: 4.w),
                              Text(
                                'Clan Leader',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 14.w, color: AppColors.onSurfaceVariant),
                              SizedBox(width: 4.w),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      user.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '@${user.username ?? user.name.toLowerCase().replaceAll(' ', '.')}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      user.bio ?? 'Explorer by heart, builder by passion. Finding amazing people & creating unforgettable memories. ✨',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5,
                        color: AppColors.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildReputationCard(user.reputation),
        ],
      ),
    );
  }
   Widget _buildHeader(BuildContext context, UserModel user) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔹 Title Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    'Your tribe, your journey',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFF97316), // orange accent
                      shape: BoxShape.circle,
                    ),
                  )
                ],
              ),
            ],
          ),

          // 🔹 Actions (right side icons)
          Row(
            children: [
              _buildIconButton(Icons.share_outlined, onTap: () => _shareProfile(user)),
              SizedBox(width: 10.w),
              _buildIconButton(Icons.settings_outlined, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }),
            ],
          )
        ],
      ),
    );
  }

  void _shareProfile(UserModel user) {
    // 🔹 Bridge URL on your Next.js site
    final String shareUrl = "https://devsonireactnative.netlify.app/share/${user.id}";
    
    final String message = "Check out ${user.name}'s profile on Meetra! Connect and discover tribes together. ✨\n\n$shareUrl";
    Share.share(message);
  }

  Widget _buildIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE3E7E4)),
        ),
        child: Icon(
          icon,
          size: 20.w,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReputationCard(int reputation) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft:Radius.circular(32),bottomRight:Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 28.w),
          ),
          SizedBox(width: 16.w),
          Expanded(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Reputation',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.info_outline, size: 14.w, color: AppColors.onSurfaceVariant),
                  ],
                ),
                Text(
                  reputation.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expert',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Top 8% of Meetra',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int joined, int owned, int reputation) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(Icons.people_outline_rounded, joined.toString(), 'Clans Joined', Colors.orange),
        _buildStatCard(Icons.workspace_premium_outlined, owned.toString(), 'Clans Owned', Colors.blue),
        _buildStatCard(Icons.stars_rounded, '${(reputation/1000).toStringAsFixed(1)}K', 'Reputation', Colors.green),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color accentColor) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.w, color: accentColor),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserModel user) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
              );
            },
            icon: Icon(Icons.person_outline_rounded, size: 20.w),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              elevation: 0,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareProfile(user),
            icon: Icon(Icons.share_outlined, size: 20.w),
            label: const Text('Share Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClanTabs(List<ClanModel> owned, List<ClanModel> joined, String userId) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16.sp),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16.sp),
          tabs: const [
            Tab(text: 'My Clans'),
            Tab(text: 'Joined Clans'),
          ],
        ),
        SizedBox(height: 20.h),
        SizedBox(
          height: 400.h, // Fixed height for scrollable area, or use SliverList
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildClanList(owned, true),
              _buildClanList(joined, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClanList(List<ClanModel> clans, bool isOwned) {
    if (clans.isEmpty) {
      return Center(
        child: Text(
          isOwned ? 'You haven\'t created any clans yet.' : 'You haven\'t joined any clans yet.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clans.length,
      itemBuilder: (context, index) {
        final clan = clans[index];
        return _buildClanCard(context, clan, isOwned);
      },
    );
  }

  Widget _buildClanCard(BuildContext context, ClanModel clan, bool isOwned) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClanDetailScreen(clan: clan)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                image: DecorationImage(
                  image: NetworkImage(clan.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isOwned ? const Color(0xFFFFF4F2) : const Color(0xFFF2FFF4),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isOwned ? 'Owned' : 'Joined',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: isOwned ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                      Icon(Icons.more_horiz_rounded, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    clan.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.people_outline_rounded, size: 14.w, color: AppColors.onSurfaceVariant),
                      SizedBox(width: 4.w),
                      Text(
                        '${clan.memberCount} Members • ${clan.categories.isNotEmpty ? clan.categories.first : "General"}',
                        style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant),
                      ),
  
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildAvatarStack(),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    return Row(
      children: [
        for (int i = 0; i < 3; i++)
          Align(
            widthFactor: 0.6,
            child: CircleAvatar(
              radius: 12.r,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 10.r,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$i'),
              ),
            ),
          ),
        SizedBox(width: 10.w),
        Text(
          '+24',
          style: TextStyle(fontSize: 10.sp, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
