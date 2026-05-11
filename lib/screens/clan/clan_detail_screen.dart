import 'package:flutter/material.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ClanDetailScreen extends StatelessWidget {
  final ClanModel clan;

  const ClanDetailScreen({super.key, required this.clan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(clan.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: CachedNetworkImage(
                imageUrl: clan.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildChip('${clan.memberCount} Members', Icons.people_rounded),
                      const SizedBox(width: 12),
                      _buildChip('${clan.totalEvents} Events', Icons.event_rounded),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About this Clan',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clan.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Join this Clan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
