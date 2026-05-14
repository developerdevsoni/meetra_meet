import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/models/event_model.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isNear = false;
  bool _isEventDay = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    // Periodically check location if it's the event day
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isEventDay) _checkLocation();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final event = await _firestoreService.getEventStream(widget.eventId).first;
    if (event != null) {
      final now = DateTime.now();
      final isSameDay = event.eventDate.year == now.year &&
          event.eventDate.month == now.month &&
          event.eventDate.day == now.day;
      
      setState(() {
        _isEventDay = isSameDay;
      });

      if (isSameDay) {
        _checkLocation();
      }
    }
  }

  Future<void> _checkLocation() async {
    try {
      final event = await _firestoreService.getEventStream(widget.eventId).first;
      if (event == null || event.latitude == null || event.longitude == null) return;

      final position = await Geolocator.getCurrentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        event.latitude!,
        event.longitude!,
      );

      setState(() {
        _isNear = distance <= 100; // 100 meters radius
      });
    } catch (e) {
      print('Location check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<EventModel?>(
        stream: _firestoreService.getEventStream(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final event = snapshot.data;
          if (event == null) return const Center(child: Text('Event not found'));

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(event),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventHeader(event),
                      SizedBox(height: 24.h),
                      _buildDescription(event),
                      SizedBox(height: 24.h),
                      _buildLocationMap(event),
                      SizedBox(height: 24.h),
                      _buildAttendanceSection(event),
                      SizedBox(height: 100.h), // Spacing for bottom button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildSliverAppBar(EventModel event) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: event.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: AppColors.primary.withOpacity(0.05), child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (context, url, error) => Container(color: AppColors.primary.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildEventHeader(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: GoogleFonts.plusJakartaSans(fontSize: 28.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20.w),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('EEEE, MMM dd').format(event.eventDate), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                Text(DateFormat('hh:mm a').format(event.eventDate), style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: const Color(0xFF1F8A70).withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.location_on_rounded, color: const Color(0xFF1F8A70), size: 20.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.location, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('View on Map', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About Event', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Text(
          event.description,
          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildLocationMap(EventModel event) {
    if (event.latitude == null || event.longitude == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(event.latitude!, event.longitude!),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.meetra.meet',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(event.latitude!, event.longitude!),
                      width: 40.w,
                      height: 40.w,
                      child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Open in external maps
              // final url = 'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}';
              // Actually better to use url_launcher if available, but I'll stick to basic for now
            },
            icon: const Icon(Icons.directions_rounded),
            label: const Text('Get Directions'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              side: const BorderSide(color: AppColors.primary),
              foregroundColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Attendees', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            Text('${event.participants.length} Joined', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 16.h),
        if (event.participants.isEmpty)
          const Center(child: Text('No one has joined yet.'))
        else
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: event.participants.map((userId) => _buildParticipantAvatar(userId, event.attendees.contains(userId))).toList(),
          ),
        if (event.attendees.isNotEmpty) ...[
          SizedBox(height: 24.h),
          Text('Live Check-ins', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: event.attendees.map((userId) => _buildAttendeeTile(userId)).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildParticipantAvatar(String userId, bool isCheckedIn) {
    return FutureBuilder(
      future: _firestoreService.getUser(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Tooltip(
          message: user?.name ?? 'Loading...',
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCheckedIn ? AppColors.success : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24.r,
                  backgroundImage: user?.photoUrl != null ? CachedNetworkImageProvider(user!.photoUrl!) : null,
                  child: user?.photoUrl == null ? const Icon(Icons.person) : null,
                ),
              ),
              if (isCheckedIn)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: Icon(Icons.check, size: 10.w, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendeeTile(String userId) {
    return FutureBuilder(
      future: _firestoreService.getUser(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundImage: user?.photoUrl != null ? CachedNetworkImageProvider(user!.photoUrl!) : null,
                child: user?.photoUrl == null ? const Icon(Icons.person, size: 20) : null,
              ),
              SizedBox(width: 12.w),
              Text(user?.name ?? 'Loading...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
              const Spacer(),
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16.w),
            ],
          ),
        );
      },
    );
  }

  Widget? _buildBottomAction() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const SizedBox.shrink();
        final currentUserId = authState.user.id;

        return StreamBuilder<EventModel?>(
          stream: _firestoreService.getEventStream(widget.eventId),
          builder: (context, snapshot) {
            final event = snapshot.data;
            if (event == null) return const SizedBox.shrink();

            final isAttending = event.participants.contains(currentUserId);
            final isCheckedIn = event.attendees.contains(currentUserId);

            if (!isAttending) {
              return _buildActionButton('Join Event', () => _firestoreService.joinEvent(widget.eventId, currentUserId));
            }

            if (_isEventDay && _isNear && !isCheckedIn) {
              return _buildActionButton('I am in', () => _firestoreService.markAttendance(widget.eventId, currentUserId), color: AppColors.success);
            }

            if (isCheckedIn) {
              return _buildActionButton('Checked In', null, color: AppColors.success.withOpacity(0.5));
            }

            return _buildActionButton('Event Starts Soon', null, color: AppColors.outlineVariant);
          },
        );
      },
    );
  }

  Widget _buildActionButton(String text, VoidCallback? onPressed, {Color? color}) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            elevation: 0,
          ),
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
