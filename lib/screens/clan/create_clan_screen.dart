import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/blocs/clan/clan_state.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/services/upload_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class CreateClanScreen extends StatefulWidget {
  const CreateClanScreen({super.key});

  @override
  State<CreateClanScreen> createState() => _CreateClanScreenState();
}

class _CreateClanScreenState extends State<CreateClanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _categoriesController = TextEditingController();
  
  XFile? _pickedXFile;
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _pickedXFile = pickedFile;
        if (!kIsWeb) {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      final currentUser = authState.user;

      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = (await UploadService().uploadImage(_imageFile!)) ?? '';
      }

      final clanId = const Uuid().v4(); // Generate 128-bit UUID for the clan
      
      final categories = _categoriesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final clan = ClanModel(
        id: clanId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: imageUrl.isEmpty ? _getDefaultImage(categories) : imageUrl,
        adminId: currentUser.id, // Using the actual 128-bit UID from Firebase
        adminName: currentUser.name,
        memberCount: 1,
        totalEvents: 0,
        isPremium: false,
        categories: categories,
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        createdAt: DateTime.now(),
      );

      context.read<ClanBloc>().add(CreateClanRequested(clan));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClanBloc, ClanState>(
      listener: (context, state) {
        if (state is ClanOperationSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clan launched successfully!')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Launch Your Clan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          elevation: 0,
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
                      _buildTextField(_nameController, 'Clan Name', Icons.groups_rounded, 'Enter a catchy name'),
                      SizedBox(height: 20.h),
                      _buildTextField(_descriptionController, 'Description (Optional)', Icons.description_rounded, 'What is your clan about?', maxLines: 3),
                      SizedBox(height: 20.h),
                      _buildTextField(_categoriesController, 'Categories', Icons.category_rounded, 'e.g. Fitness, Music, Yoga (comma separated)'),
                      SizedBox(height: 32.h),
                      Text('Location', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18.sp)),
                      SizedBox(height: 16.h),
                      _buildTextField(_cityController, 'City', Icons.location_city_rounded, 'e.g. Jodhpur'),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_stateController, 'State', Icons.map_rounded, 'e.g. Rajasthan')),
                          SizedBox(width: 16.w),
                          Expanded(child: _buildTextField(_countryController, 'Country', Icons.public_rounded, 'e.g. India')),
                        ],
                      ),
                      SizedBox(height: 48.h),
                      SizedBox(
                        width: double.infinity,
                        height: 60.h,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                            elevation: 0,
                          ),
                          child: Text('Launch Clan', style: GoogleFonts.plusJakartaSans(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.none),
        ),
        child: (_imageFile != null || (kIsWeb && _pickedXFile != null))
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: kIsWeb 
                  ? Image.network(_pickedXFile!.path, fit: BoxFit.cover)
                  : Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: 40.w, color: AppColors.primary),
                  SizedBox(height: 8.h),
                  const Text('Add Clan Banner (Optional)', style: TextStyle(color: AppColors.onSurfaceVariant)),
                ],
              ),
      ),
    );
  }

  String _getDefaultImage(List<String> categories) {
    if (categories.isEmpty) return 'https://images.unsplash.com/photo-1511632765486-a01980e01a18'; // Social default

    final category = categories.first.toLowerCase();
    
    if (category.contains('gaming')) return 'https://images.unsplash.com/photo-1542751371-adc38448a05e';
    if (category.contains('music')) return 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4';
    if (category.contains('fit') || category.contains('gym') || category.contains('workout')) return 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438';
    if (category.contains('tech') || category.contains('code') || category.contains('dev')) return 'https://images.unsplash.com/photo-1518770660439-4636190af475';
    if (category.contains('art') || category.contains('paint') || category.contains('design')) return 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b';
    
    return 'https://images.unsplash.com/photo-1511632765486-a01980e01a18'; // Social default
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 22.w),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
      ),
      validator: (value) {
        if (label != 'Description (Optional)' && label != 'Add Clan Banner (Optional)' && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
