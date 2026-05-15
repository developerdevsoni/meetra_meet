import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/models/event_model.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:meetra_meet/services/upload_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';

class EventPlannerScreen extends StatefulWidget {
  final ClanModel clan;

  const EventPlannerScreen({super.key, required this.clan});

  @override
  State<EventPlannerScreen> createState() => _EventPlannerScreenState();
}

class _EventPlannerScreenState extends State<EventPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  File? _imageFile;
  bool _isLoading = false;
  List<dynamic> _locationSuggestions = [];
  bool _isSearchingLocation = false;
  double? _selectedLat;
  double? _selectedLng;
  String? _mapboxToken;
  final MapController _mapController = MapController();
  
  bool _isPaid = false;
  final _feesController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMapboxToken();
  }

  Future<void> _loadMapboxToken() async {
    final token = await FirestoreService().getMapboxToken();
    setState(() => _mapboxToken = token);
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty || _mapboxToken == null) {
      setState(() => _locationSuggestions = []);
      return;
    }

    setState(() => _isSearchingLocation = true);

    try {
      // Mapbox Suggest API
      final url = 'https://api.mapbox.com/search/searchbox/v1/suggest?q=${Uri.encodeComponent(query)}&access_token=$_mapboxToken&session_token=${const Uuid().v4()}';
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        setState(() => _locationSuggestions = response.data['suggestions'] ?? []);
      }
    } catch (e) {
      debugPrint('Mapbox search error: $e');
    } finally {
      setState(() => _isSearchingLocation = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final currentUser = authState.user;

      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = (await UploadService().uploadImage(_imageFile!)) ?? '';
      }

      final finalDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute
      );

      final event = EventModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        clanId: widget.clan.id,
        plannerId: currentUser.id,
        location: _locationController.text.trim(),
        latitude: _selectedLat,
        longitude: _selectedLng,
        eventDate: finalDateTime,
        imageUrl: imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1000' : imageUrl,
        participants: [currentUser.id],
        isPremium: false,
        isPaid: _isPaid,
        fees: _isPaid ? _feesController.text.trim() : '',
        ageLimit: _ageController.text.trim(),
        plannerContact: _contactController.text.trim(),
        createdAt: DateTime.now(),
      );

      await FirestoreService().createEvent(event);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event planned successfully! Notification sent.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Plan New Event', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    SizedBox(height: 32.h),
                    _buildTextField(_titleController, 'Event Title', Icons.event_rounded),
                    SizedBox(height: 20.h),
                    _buildTextField(_descController, 'Description', Icons.description_rounded, maxLines: 3),
                    SizedBox(height: 20.h),
                    _buildLocationField(),
                    if (_locationSuggestions.isNotEmpty) _buildSuggestionsList(),
                    if (_selectedLat != null && _selectedLng != null) ...[
                      SizedBox(height: 16.h),
                      _buildMapPreview(),
                    ],
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(child: _buildPickerTile('Date', DateFormat('yMMMd').format(_selectedDate), Icons.calendar_month_rounded, _pickDate)),
                        SizedBox(width: 16.w),
                        Expanded(child: _buildPickerTile('Time', _selectedTime.format(context), Icons.access_time_rounded, _pickTime)),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    _buildPaidSelection(),
                    if (_isPaid) ...[
                      SizedBox(height: 20.h),
                      _buildTextField(_feesController, 'Entry Fees (INR)', Icons.payments_rounded, keyboardType: TextInputType.number),
                    ],
                    SizedBox(height: 20.h),
                    _buildTextField(_ageController, 'Age Bar (e.g. 18-35)', Icons.person_pin_circle_rounded),
                    SizedBox(height: 20.h),
                    _buildTextField(_contactController, 'Planner Contact Number', Icons.phone_rounded, keyboardType: TextInputType.phone),
                    SizedBox(height: 48.h),
                    SizedBox(
                      width: double.infinity,
                      height: 60.h,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
                        child: Text('Confirm Event', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160.h, width: double.infinity,
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(24.r)),
        child: _imageFile != null
            ? ClipRRect(borderRadius: BorderRadius.circular(24.r), child: Image.file(_imageFile!, fit: BoxFit.cover))
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, size: 40.w, color: AppColors.primary), SizedBox(height: 8.h), const Text('Event Banner (Recommended)')]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller, maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true, fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (value) => _searchLocations(value),
      decoration: InputDecoration(
        labelText: 'Meeting Point / Location',
        prefixIcon: Icon(Icons.location_on_rounded, color: AppColors.primary),
        suffixIcon: _isSearchingLocation 
            ? SizedBox(width: 20.w, height: 20.w, child: const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) 
            : null,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _locationSuggestions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = _locationSuggestions[index];
          return ListTile(
            leading: const Icon(Icons.location_city_rounded, size: 20, color: AppColors.primary),
            title: Text(suggestion['name'] ?? '', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
            subtitle: Text(suggestion['full_address'] ?? suggestion['place_formatted'] ?? '', style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () async {
              // For Mapbox suggestions, we might need another call to retrieve coordinates (retrieve API)
              // or check if they are in the suggestion (usually suggest doesn't have coords, retrieve does)
              // Let's assume we need to call retrieve API to get the coordinates from mapbox_id
              final mapboxId = suggestion['mapbox_id'];
              if (mapboxId != null && _mapboxToken != null) {
                setState(() => _isSearchingLocation = true);
                try {
                  final retrieveUrl = 'https://api.mapbox.com/search/searchbox/v1/retrieve/$mapboxId?access_token=$_mapboxToken&session_token=${const Uuid().v4()}';
                  final response = await Dio().get(retrieveUrl);
                  if (response.statusCode == 200) {
                    final feature = response.data['features'][0];
                    final coords = feature['geometry']['coordinates'];
                    setState(() {
                      _locationController.text = suggestion['full_address'] ?? suggestion['name'];
                      _selectedLat = coords[1];
                      _selectedLng = coords[0];
                      _locationSuggestions = [];
                    });
                    _mapController.move(LatLng(_selectedLat!, _selectedLng!), 15);
                  }
                } catch (e) {
                  debugPrint('Mapbox retrieve error: $e');
                } finally {
                  setState(() => _isSearchingLocation = false);
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildPickerTile(String label, String value, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant)),
            SizedBox(height: 4.h),
            Row(children: [Icon(icon, size: 18.w, color: AppColors.primary), SizedBox(width: 8.w), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected Location', style: GoogleFonts.plusJakartaSans(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Container(
          height: 180.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_selectedLat ?? 26.2389, _selectedLng ?? 73.0243),
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
                      point: LatLng(_selectedLat!, _selectedLng!),
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
      ],
    );
  }

  Widget _buildPaidSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Event Type', style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Free'),
                value: false,
                groupValue: _isPaid,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isPaid = v!),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Paid'),
                value: true,
                groupValue: _isPaid,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isPaid = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
