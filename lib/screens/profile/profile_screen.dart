import 'package:flutter/material.dart';
import 'package:meetra_meet/services/auth_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
            ),
            const SizedBox(height: 16),
            Text(
              'Soni Dev',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'Explorer & Clan Leader',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            _buildStatRow(),
            const SizedBox(height: 32),
            _buildProfileMenu(context, authService),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('12', 'Clans'),
        _buildStatItem('45', 'Events'),
        _buildStatItem('1.2k', 'Followers'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }

  Widget _buildProfileMenu(BuildContext context, AuthService authService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline_rounded, 'Account Settings'),
          _buildMenuItem(Icons.notifications_outlined, 'Notifications'),
          _buildMenuItem(Icons.security_rounded, 'Privacy & Security'),
          _buildMenuItem(Icons.help_outline_rounded, 'Help Center'),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              await authService.signOut();
              // Navigate back to onboarding or login
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {},
    );
  }
}
