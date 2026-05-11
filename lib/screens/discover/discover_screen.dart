import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/blocs/clan/clan_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/screens/clan/clan_detail_screen.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    // Load all clans for discovery
    context.read<ClanBloc>().add(const LoadClansByLocation(""));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Discover Tribes', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search clans or interests...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _buildCategoryChip('All Tribes', true),
                _buildCategoryChip('Fitness', false),
                _buildCategoryChip('Music', false),
                _buildCategoryChip('Adventure', false),
                _buildCategoryChip('Tech', false),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ClanBloc, ClanState>(
              builder: (context, state) {
                if (state is ClanLoading) return const Center(child: CircularProgressIndicator());
                if (state is ClanLoaded) {
                  if (state.clans.isEmpty) return _buildEmptyState();
                  return GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.w,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: state.clans.length,
                    itemBuilder: (context, index) => _buildClanGridCard(state.clans[index]),
                  );
                }
                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClanGridCard(ClanModel clan) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClanDetailScreen(clan: clan))),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                child: Image.network(clan.imageUrl, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clan.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${clan.memberCount} members', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11.sp)),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 10, color: AppColors.primary),
                      SizedBox(width: 4.w),
                      Text(clan.city, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_off_rounded, size: 60.w, color: AppColors.outlineVariant),
          SizedBox(height: 16.h),
          const Text('No tribes found. Start one?'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        side: BorderSide.none,
      ),
    );
  }
}
