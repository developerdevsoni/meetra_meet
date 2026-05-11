import 'package:flutter/material.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/services/firestore_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Clan Feed',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<ClanModel>>(
        stream: firestoreService.getClans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final clans = snapshot.data ?? _getDummyClans();
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clans.length,
            itemBuilder: (context, index) {
              return _buildClanCard(context, clans[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildClanCard(BuildContext context, ClanModel clan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clan Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: clan.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.surfaceVariant),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
                if (clan.isPremium)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      clan.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.people_alt_rounded, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${clan.memberCount}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(Icons.person, size: 14, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Admin: ${clan.adminName}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${clan.totalEvents} Events',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ClanModel> _getDummyClans() {
    return [
      ClanModel(
        id: '1',
        name: 'The Hikers',
        description: 'Exploring the peaks',
        imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306',
        adminId: 'admin1',
        adminName: 'Soni Dev',
        memberCount: 1240,
        totalEvents: 12,
        isPremium: true,
        categories: ['Adventure'],
        createdAt: DateTime.now(),
      ),
      ClanModel(
        id: '2',
        name: 'Urban Runners',
        description: 'Morning city runs',
        imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8',
        adminId: 'admin2',
        adminName: 'Alice',
        memberCount: 850,
        totalEvents: 5,
        isPremium: false,
        categories: ['Fitness'],
        createdAt: DateTime.now(),
      ),
    ];
  }
}
