import 'package:flutter/material.dart';
import 'package:meetra_meet/utils/theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Top Clans'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: index < 3 ? Border.all(color: Colors.amber.withOpacity(0.5), width: 1) : null,
            ),
            child: Row(
              children: [
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: index < 3 ? Colors.amber : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mountain Goats', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('4.2k activity score', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                if (index < 3)
                  const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
