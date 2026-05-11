import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
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
        plannerId: currentUser.uid,
        location: _locationController.text.trim(),
        eventDate: finalDateTime,
        imageUrl: imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1000' : imageUrl,
        participants: [currentUser.uid],
        isPremium: false,
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
                    _buildTextField(_locationController, 'Meeting Point / Location', Icons.location_on_rounded),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(child: _buildPickerTile('Date', DateFormat('yMMMd').format(_selectedDate), Icons.calendar_month_rounded, _pickDate)),
                        SizedBox(width: 16.w),
                        Expanded(child: _buildPickerTile('Time', _selectedTime.format(context), Icons.access_time_rounded, _pickTime)),
                      ],
                    ),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller, maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true, fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
}
