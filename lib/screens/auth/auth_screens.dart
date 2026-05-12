import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Pop the login screen so AuthWrapper can show MainNavigation
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Welcome back',
                style: GoogleFonts.outfit(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Sign in to continue to your clans',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 48.h),
              
              // Google Sign In Button
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  return _buildSocialButton(
                    context,
                    isLoading ? 'Signing in...' : 'Continue with Google',
                    Icons.login_rounded,
                    Colors.white,
                    Colors.black87,
                    isLoading ? null : () {
                      context.read<AuthBloc>().add(AuthSignInRequested());
                    },
                  );
                },
              ),
              
              SizedBox(height: 16.h),
              
              // Phone Sign In Button
              _buildSocialButton(
                context,
                'Continue with Phone',
                Icons.phone_android_rounded,
                AppColors.primary,
                Colors.white,
                () {
                  // Phone Auth placeholder
                },
              ),
              
              const Spacer(),
              
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
    );
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
      height: 60.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          side: bgColor == Colors.white ? const BorderSide(color: AppColors.outlineVariant) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22.w),
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
