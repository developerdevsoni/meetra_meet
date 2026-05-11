import 'package:flutter/material.dart';
import 'package:meetra_meet/screens/auth/auth_screens.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Find your people',
      'description': 'Clans is where interests become communities. Discover active groups that match your passion.',
      'image': 'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&q=80&w=1000',
    },
    {
      'title': 'Attend Events',
      'description': 'Real-world meetups and activities organized by your favorite clans.',
      'image': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&q=80&w=1000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Image.network(
                _onboardingData[index]['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withOpacity(0.8),
                  AppColors.background,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bars
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 6,
                        width: index == _currentPage ? 48 : 16,
                        decoration: BoxDecoration(
                          color: index == _currentPage ? AppColors.primary : AppColors.onSurfaceVariant,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Text Content
                  Text(
                    _onboardingData[_currentPage]['title']!,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _onboardingData[_currentPage]['description']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Feature Bento (Simple version)
                  Row(
                    children: [
                      Expanded(
                        child: _buildBentoCard(
                          context,
                          'Join clans',
                          'Niche interest groups',
                          Icons.explore_rounded,
                          AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBentoCard(
                          context,
                          'Events',
                          'Real-world meetups',
                          Icons.calendar_today_rounded,
                          AppColors.tertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Get Started'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                          children: [
                            TextSpan(
                              text: 'Log in',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.onSurface, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
