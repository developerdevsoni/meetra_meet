import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/blocs/clan/clan_state.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Clan Leaderboard', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<ClanBloc, ClanState>(
        builder: (context, state) {
          if (state is ClanLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is ClanLoaded) {
            // Sort clans by member count descending
            final sortedClans = List.from(state.clans);
            sortedClans.sort((a, b) => b.memberCount.compareTo(a.memberCount));

            if (sortedClans.isEmpty) {
              return const Center(child: Text('No clans found.'));
            }

            return ListView.builder(
              padding: EdgeInsets.all(24.w),
              itemCount: sortedClans.length,
              itemBuilder: (context, index) {
                final clan = sortedClans[index];
                final rank = index + 1;
                
                return _buildRankCard(context, rank, clan);
              },
            );
          }
          
          return const Center(child: Text('Failed to load leaderboard.'));
        },
      ),
    );
  }

  Widget _buildRankCard(BuildContext context, int rank, dynamic clan) {
    bool isTopThree = rank <= 3;
    Color rankColor = rank == 1 ? Colors.amber : (rank == 2 ? const Color(0xFFC0C0C0) : (rank == 3 ? const Color(0xFFCD7F32) : AppColors.onSurfaceVariant));

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
        border: isTopThree ? Border.all(color: rankColor.withOpacity(0.3), width: 1.5) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: rankColor,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          CircleAvatar(
            radius: 28.r,
            backgroundImage: NetworkImage(clan.imageUrl),
            backgroundColor: AppColors.secondaryContainer,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clan.name,
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
                Text(
                  '${clan.memberCount} Members',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          if (isTopThree)
            Icon(Icons.emoji_events_rounded, color: rankColor, size: 24.w),
        ],
      ),
    );
  }
}
