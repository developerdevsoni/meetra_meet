import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/screens/clan/event_planner_screen.dart';
import 'package:meetra_meet/screens/chat/chat_screens.dart';
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
  List<UserModel> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final members = await FirestoreService().getClanMembers(widget.clan.id);
    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

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
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_members.isEmpty)
                    _buildEmptyMembersState()
                  else
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
    final isAdmin = user.id == widget.clan.adminId;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthAuthenticated ? authState.user.uid : null;

        return GestureDetector(
          onTap: () {
            if (currentUserId != null && currentUserId != user.id) {
              final chatId = currentUserId.compareTo(user.id) < 0 
                  ? '${currentUserId}_${user.id}' 
                  : '${user.id}_$currentUserId';
                  
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(
                    chatId: chatId,
                    title: user.name,
                  ),
                ),
              );
            } else if (currentUserId == user.id) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You cannot chat with yourself!')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to chat.')));
            }
          },
          child: Container(
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
                      Row(
                        children: [
                          Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 8.w),
                          _buildRoleTag(isAdmin),
                        ],
                      ),
                      Text(isAdmin ? 'Clan Administrator' : 'Member since recently', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.star_outline_rounded, color: Colors.amber),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Star given to ${user.name}!')));
                  },
                ),
                Icon(Icons.chat_bubble_outline_rounded, size: 20.r, color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleTag(bool isAdmin) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.primary : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        isAdmin ? 'ADMIN' : 'MEMBER',
        style: TextStyle(
          color: isAdmin ? Colors.white : AppColors.onSurfaceVariant,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
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

  Widget _buildEmptyMembersState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded, size: 48.r, color: AppColors.onSurfaceVariant.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(
            'No members yet',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
          ),
          Text(
            'Share your clan to invite members!',
            style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
