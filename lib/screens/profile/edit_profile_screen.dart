import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/models/user_model.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:meetra_meet/utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username ?? '');
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    final updatedUser = UserModel(
      id: widget.user.id,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: widget.user.email,
      bio: _bioController.text.trim(),
      reputation: widget.user.reputation,
      phoneNumber: widget.user.phoneNumber,
      photoUrl: widget.user.photoUrl,
      joinedClans: widget.user.joinedClans,
      ownedClans: widget.user.ownedClans,
      fcmToken: widget.user.fcmToken,
      createdAt: widget.user.createdAt,
    );

    try {
      await FirestoreService().updateUser(updatedUser);
      if (mounted) {
        context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: widget.user.photoUrl != null 
                    ? NetworkImage(widget.user.photoUrl!) 
                    : null,
                  child: widget.user.photoUrl == null 
                    ? Icon(Icons.person, size: 60.r, color: AppColors.primary) 
                    : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.w),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            _buildTextField('Full Name', _nameController, 'Enter your name'),
            SizedBox(height: 20.h),
            _buildTextField('Username', _usernameController, '@username', prefix: '@'),
            SizedBox(height: 20.h),
            _buildTextField('Bio', _bioController, 'Tell us about yourself...', maxLines: 4),
            if (_isLoading) ...[
              SizedBox(height: 32.h),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}
