import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/screens/main_navigation.dart';
import 'package:meetra_meet/screens/onboarding_screen.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
            (route) => false,
          );
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen())),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSignUp ? 'Create Account' : 'Welcome back',
                  style: GoogleFonts.outfit(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _isSignUp ? 'Join the community today' : 'Sign in to continue to your clans',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 40.h),
                
                if (_isSignUp) ...[
                  _buildTextField('Full Name', _nameController, Icons.person_outline_rounded),
                  SizedBox(height: 16.h),
                ],
                _buildTextField('Email Address', _emailController, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                SizedBox(height: 16.h),
                _buildTextField('Password', _passwordController, Icons.lock_outline_rounded, isPassword: true),
                
                SizedBox(height: 32.h),
                
                // Email Sign In/Up Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleEmailAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          elevation: 0,
                        ),
                        child: isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_isSignUp ? 'Create Account' : 'Sign In', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 24.h),
                
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.outlineVariant)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text('OR', style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: AppColors.outlineVariant)),
                  ],
                ),
                
                SizedBox(height: 24.h),
                
                // Google Sign In Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return _buildSocialButton(
                      context,
                      'Continue with Google',
                      Icons.login_rounded,
                      Colors.white,
                      Colors.black87,
                      isLoading ? null : () {
                        context.read<AuthBloc>().add(AuthSignInRequested());
                      },
                    );
                  },
                ),
                
                SizedBox(height: 24.h),
                
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Already have an account? Sign In' : 'New here? Create an Account',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                Center(
                  child: Text(
                    'By continuing, you agree to our Terms and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20.w, color: AppColors.onSurfaceVariant),
            hintText: 'Enter your ${label.toLowerCase()}',
            hintStyle: TextStyle(fontWeight: FontWeight.normal, color: AppColors.onSurfaceVariant.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          ),
          validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  void _handleEmailAuth() {
    if (_formKey.currentState!.validate()) {
      if (_isSignUp) {
        context.read<AuthBloc>().add(AuthEmailSignUpRequested(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ));
      } else {
        context.read<AuthBloc>().add(AuthEmailSignInRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ));
      }
    }
  }

  Widget _buildSocialButton(
    BuildContext context,
    String text,
    IconData icon,
    Color bgColor,
    Color textColor,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          side: bgColor == Colors.white ? const BorderSide(color: AppColors.outlineVariant) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.w),
            SizedBox(width: 12.w),
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
