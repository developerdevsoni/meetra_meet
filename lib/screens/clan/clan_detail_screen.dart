import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/event_model.dart';
import 'package:meetra_meet/screens/clan/clan_admin_screen.dart';
import 'package:meetra_meet/screens/clan/event_planner_screen.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class ClanDetailScreen extends StatefulWidget {
  final ClanModel clan;

  const ClanDetailScreen({super.key, required this.clan});

  @override
  State<ClanDetailScreen> createState() => _ClanDetailScreenState();
}

class _ClanDetailScreenState extends State<ClanDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<EventModel> _clanEvents = [];
  bool _isLoadingEvents = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    FirestoreService().getClanEvents(widget.clan.id).listen((events) {
      if (mounted) {
        setState(() {
          _clanEvents = events;
          _isLoadingEvents = false;
        });
      }
    });
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    return _clanEvents.where((event) => isSameDay(event.eventDate, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.uid == widget.clan.adminId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isAdmin),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeroInfo(isAdmin),
                _buildTabs(),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalendarSection(),
                      SizedBox(height: 24.h),
                      _buildSelectedDayEvents(),
                      SizedBox(height: 32.h),
                      Text('Upcoming Events', style: GoogleFonts.plusJakartaSans(fontSize: 22.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16.h),
                      _isLoadingEvents 
                          ? const Center(child: CircularProgressIndicator())
                          : _clanEvents.isEmpty 
                              ? _buildEmptyEvents()
                              : Column(
                                  children: _clanEvents.map((e) => _buildEventCard(e)).toList(),
                                ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isAdmin ? _buildJoinAction(context) : null,
    );
  }

  Widget _buildAppBar(BuildContext context, bool isAdmin) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(widget.clan.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.primary.withOpacity(0.1))),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.2), Colors.transparent, AppColors.surface],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isAdmin)
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClanAdminScreen(clan: widget.clan))),
            icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
            label: const Text('Manage', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        IconButton(icon: const Icon(Icons.share_rounded, color: AppColors.onSurface), onPressed: () {}),
      ],
    );
  }

  Widget _buildHeroInfo(bool isAdmin) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(color: AppColors.tertiaryContainer.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
                child: const Text('Verified Clan', style: TextStyle(color: AppColors.tertiary, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const Spacer(),
              if (isAdmin)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: const Text('Admin View', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(widget.clan.name, style: GoogleFonts.plusJakartaSans(fontSize: 28.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 8.h),
          Text(widget.clan.description, style: TextStyle(fontSize: 14.sp, color: AppColors.onSurfaceVariant, height: 1.5)),
          SizedBox(height: 24.h),
          Row(
            children: [
              _buildSmallIconText(Icons.group_rounded, '${widget.clan.memberCount} Members'),
              SizedBox(width: 24.w),
              _buildSmallIconText(Icons.location_on_rounded, widget.clan.city),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        eventLoader: _getEventsForDay,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ),
    );
  }

  Widget _buildSelectedDayEvents() {
    if (_selectedDay == null) return const SizedBox.shrink();
    final events = _getEventsForDay(_selectedDay!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Events for ${_selectedDay!.day}/${_selectedDay!.month}', style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        if (events.isEmpty)
          const Text('No events scheduled for this day.')
        else
          ...events.map((e) => _buildEventCard(e)),
      ],
    );
  }

  Widget _buildEmptyEvents() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 60.w, color: AppColors.outlineVariant),
          SizedBox(height: 16.h),
          const Text('No upcoming events yet.'),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(event.imageUrl, width: 80.w, height: 80.w, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80.w, height: 80.w, color: Colors.grey[200])),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 4.w),
                    Text(event.location, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text('${event.eventDate.hour}:${event.eventDate.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceContainerLow))),
      child: Row(
        children: [
          _buildTabItem('Schedule', true),
          _buildTabItem('Members', false),
          _buildTabItem('Media', false),
        ],
      ),
    );
  }

  Widget _buildTabItem(String text, bool isSelected) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Text(text, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 14.sp)),
    );
  }

  Widget _buildJoinAction(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)), elevation: 0),
            child: Text('Join this Clan', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
