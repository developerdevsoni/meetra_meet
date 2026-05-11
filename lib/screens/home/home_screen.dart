import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/blocs/clan/clan_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/screens/clan/clan_detail_screen.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClanBloc>().add(const LoadClansByLocation("Jodhpur"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ClanBloc, ClanState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Trending Clans', 'The communities everyone is talking about.'),
                        SizedBox(height: 16.h),
                        _buildTrendingList(state),
                        SizedBox(height: 32.h),
                        _buildSectionHeader('Recommended For You', null),
                      ],
                    ),
                  ),
                ),
                _buildRecommendedSliver(state),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 32.h),
                      _buildNearbyHeader(),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
                _buildNearbySliver(state),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary),
                SizedBox(width: 8.w),
                Text(
                  'Select City',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingList(ClanState state) {
    if (state is! ClanLoaded) return const SizedBox.shrink();
    
    return SizedBox(
      height: 380.h, // Increased height to prevent overflow
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: state.clans.length,
        itemBuilder: (context, index) {
          final clan = state.clans[index];
          return _buildTrendingCard(clan, index + 1);
        },
      ),
    );
  }

  Widget _buildTrendingCard(ClanModel clan, int rank) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClanDetailScreen(clan: clan))),
      child: Container(
        width: 320.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  child: Image.network(
                    clan.imageUrl,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 180.h, color: Colors.grey[200]),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          'Rank $rank',
                          style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          clan.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.tertiary, size: 16),
                          SizedBox(width: 4.w),
                          Text('98%', style: TextStyle(color: AppColors.tertiary, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text('Admin: ${clan.adminName}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13.sp)),
                  SizedBox(height: 16.h),
                  const Divider(color: AppColors.surfaceContainerHigh),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(child: _buildMiniStat(Icons.groups_rounded, 'Members', clan.memberCount.toString())),
                      Expanded(child: _buildMiniStat(Icons.calendar_today_rounded, 'Events', '${clan.totalEvents} Monthly')),
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

  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: TextStyle(fontSize: 9.sp, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
              Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSliver(ClanState state) {
    if (state is! ClanLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildRecommendedCard(state.clans[index]),
          childCount: state.clans.length.clamp(0, 2),
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(ClanModel clan) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: Image.network(
              clan.imageUrl, 
              height: 180.h, 
              width: double.infinity, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(height: 180.h, color: Colors.grey[200]),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text('Based on your interests', style: TextStyle(color: AppColors.primary, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 12.h),
                Text(clan.name, style: GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                Text('Admin: ${clan.adminName}', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13.sp)),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.groups_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8.w),
                        Text('${clan.memberCount} Members', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: AppColors.tertiary, size: 20),
                        SizedBox(width: 4.w),
                        const Text('99%', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
                      elevation: 0,
                    ),
                    child: const Text('Join Clan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nearby Clans',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('View Map', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySliver(ClanState state) {
    if (state is! ClanLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildNearbyCard(state.clans[index]),
          childCount: state.clans.length,
        ),
      ),
    );
  }

  Widget _buildNearbyCard(ClanModel clan) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.network(
              clan.imageUrl, 
              width: 80.w, 
              height: 80.w, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(width: 80.w, height: 80.w, color: Colors.grey[200]),
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
                    Expanded(child: Text(clan.name, style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.tertiary, size: 12),
                          SizedBox(width: 4.w),
                          const Text('92%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                Text('0.8 miles away • Admin: ${clan.adminName}', style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildSmallStat(Icons.groups_rounded, '${clan.memberCount} members'),
                    SizedBox(width: 16.w),
                    _buildSmallStat(Icons.calendar_today_rounded, 'Sat 8AM'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: AppColors.onSurfaceVariant),
        SizedBox(width: 4.w),
        Text(text, style: TextStyle(fontSize: 11.sp, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
