import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/blocs/clan/clan_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/event_model.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/models/clan_media_model.dart';
import 'package:meetra_meet/screens/clan/clan_admin_screen.dart';
import 'package:meetra_meet/screens/clan/event_planner_screen.dart';
import 'package:meetra_meet/screens/chat/chat_screens.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:meetra_meet/services/media_cache_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:meetra_meet/screens/event/event_detail_screen.dart';

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
  int _selectedTabIndex = 0;
  List<UserModel> _members = [];
  List<ClanMediaModel> _media = [];
  bool _isLoadingMembers = true;
  bool _isLoadingMedia = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadMembers();
    _loadMedia();
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

  Future<void> _loadMembers() async {
    final members = await FirestoreService().getClanMembers(widget.clan.id);
    if (mounted) {
      setState(() {
        _members = members;
        _isLoadingMembers = false;
      });
    }
  }

  Future<void> _loadMedia() async {
    // Check cache first
    final cachedMedia = MediaCacheService().getCache(widget.clan.id);
    if (cachedMedia != null) {
      if (mounted) {
        setState(() {
          _media = cachedMedia;
          _isLoadingMedia = false;
        });
      }
      return;
    }

    // Fetch from Firestore
    final media = await FirestoreService().getClanMedia(widget.clan.id);
    if (mounted) {
      setState(() {
        _media = media;
        _isLoadingMedia = false;
      });
      // Save to cache
      MediaCacheService().setCache(widget.clan.id, media);
    }
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    return _clanEvents.where((event) => isSameDay(event.eventDate, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userId = authState is AuthAuthenticated ? authState.user.id : null;
        final isAdmin = userId == widget.clan.adminId;
        
        return BlocBuilder<ClanBloc, ClanState>(
          builder: (context, clanState) {
            bool isMember = false;
            if (clanState is ClanLoaded) {
              isMember = clanState.myClans.any((c) => c.id == widget.clan.id);
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              body: CustomScrollView(
                slivers: [
                  _buildAppBar(context, isAdmin),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildHeroInfo(isAdmin, isMember),
                        _buildTabs(),
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: _buildTabContent(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: (!isAdmin && !isMember) ? _buildJoinAction(context, userId) : null,
            );
          },
        );
      },
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
            CachedNetworkImage(
              imageUrl: widget.clan.imageUrl, 
              fit: BoxFit.cover, 
              placeholder: (context, url) => Container(color: AppColors.primary.withOpacity(0.05), child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
              errorWidget: (context, url, error) => Container(
                color: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 50),
              ),
            ),
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

  Widget _buildHeroInfo(bool isAdmin, bool isMember) {
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
              if (isMember)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(20.r)),
                  child: const Text('Member', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
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
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  child: Text('🎉', style: TextStyle(fontSize: 12.sp)),
                ),
              );
            }
            return null;
          },
        ),
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
      ),
      child: Container(
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
              child: CachedNetworkImage(
                imageUrl: event.imageUrl, 
                width: 80.w, 
                height: 80.w, 
                fit: BoxFit.cover, 
                placeholder: (context, url) => Container(width: 80.w, height: 80.w, color: Colors.grey[100], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                errorWidget: (context, url, error) => Container(width: 80.w, height: 80.w, color: Colors.grey[200]),
              ),
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
                      Expanded(
                        child: Text(event.location, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant,),
                          maxLines: 3, // or null for unlimited
                          overflow: TextOverflow.clip, // or visible / fade
                          softWrap: true,),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text('${event.eventDate.hour}:${event.eventDate.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Events
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        );
      case 1: // Calendar
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarSection(),
            SizedBox(height: 24.h),
            _buildSelectedDayEvents(),
            SizedBox(height: 100.h),
          ],
        );
      case 2: // Members
        return Column(
          children: [
            if (_isLoadingMembers)
              const Center(child: CircularProgressIndicator())
            else if (_members.isEmpty)
              _buildEmptyState(Icons.groups_rounded, 'No members yet')
            else
              ..._members.map((member) => _buildMemberCard(member)),
            SizedBox(height: 100.h),
          ],
        );
      case 3: // Media
        return Column(
          children: [
            if (_isLoadingMedia)
              const Center(child: CircularProgressIndicator())
            else if (_media.isEmpty)
              _buildEmptyState(Icons.photo_library_rounded, 'No media shared yet')
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.w,
                ),
                itemCount: _media.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CachedNetworkImage(
                      imageUrl: _media[index].url, 
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[100], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                    ),
                  );
                },
              ),
            SizedBox(height: 100.h),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Icon(icon, size: 64.r, color: AppColors.onSurfaceVariant.withOpacity(0.2)),
        SizedBox(height: 16.h),
        Text(message, style: TextStyle(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildMemberCard(UserModel user) {
    final isAdmin = user.id == widget.clan.adminId;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId = authState is AuthAuthenticated ? authState.user.id : null;
        
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
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.surfaceContainerLow),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(user.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
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
                      Text(isAdmin ? 'Clan Admin' : 'Member', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.pink, size: 20),
                      onPressed: () {
                        FirestoreService().likeUser(user.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reputation given to ${user.name}!')));
                      },
                    ),
                    Icon(Icons.chat_bubble_outline_rounded, size: 20.r, color: AppColors.primary),
                  ],
                ),
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
          fontSize: 8.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceContainerLow))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabItem(0, 'Events'),
            _buildTabItem(1, 'Calendar'),
            _buildTabItem(2, 'Members'),
            _buildTabItem(3, 'Media'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String text) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildJoinAction(BuildContext context, String? userId) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              if (userId != null) {
                context.read<ClanBloc>().add(JoinClanRequested(widget.clan.id, userId));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome to the clan!')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to join clans.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)), elevation: 0),
            child: Text('Join this Clan', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
