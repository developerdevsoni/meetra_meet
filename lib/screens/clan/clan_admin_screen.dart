import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/screens/clan/event_planner_screen.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ClanAdminScreen extends StatefulWidget {
  final ClanModel clan;

  const ClanAdminScreen({super.key, required this.clan});

  @override
  State<ClanAdminScreen> createState() => _ClanAdminScreenState();
}

class _ClanAdminScreenState extends State<ClanAdminScreen> {
  // Mock members for now, in a real app you'd fetch from a 'clan_members' subcollection
  final List<UserModel> _members = [
    UserModel(id: 'u1', name: 'Rahul Sharma', email: 'rahul@example.com', joinedClans: [], createdAt: DateTime.now()),
    UserModel(id: 'u2', name: 'Priya Verma', email: 'priya@example.com', joinedClans: [], createdAt: DateTime.now()),
    UserModel(id: 'u3', name: 'Amit Singh', email: 'amit@example.com', joinedClans: [], createdAt: DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Clan Management', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventPlannerScreen(clan: widget.clan))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClanSummary(),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Member Management', style: GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  ..._members.map((member) => _buildMemberCard(member)),
                  SizedBox(height: 32.h),
                  _buildQuickActions(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventPlannerScreen(clan: widget.clan))),
        label: const Text('Create Event'),
        icon: const Icon(Icons.event_available_rounded),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildClanSummary() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 40.r, backgroundImage: NetworkImage(widget.clan.imageUrl)),
          SizedBox(height: 16.h),
          Text(widget.clan.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          Text('${widget.clan.memberCount} Members • ${widget.clan.city}', style: TextStyle(color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildMemberCard(UserModel user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24.r, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Member since recently', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.star_outline_rounded, color: Colors.amber),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Star given to ${user.name}!')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
            onPressed: () {
              // Message logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Stats', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        Row(
          children: [
            _buildStatBox('Total Likes', '1.2k', Icons.favorite_rounded),
            SizedBox(width: 16.w),
            _buildStatBox('Engagements', '85%', Icons.bolt_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            SizedBox(height: 8.h),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(title, style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
