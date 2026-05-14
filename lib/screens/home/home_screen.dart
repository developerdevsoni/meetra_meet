import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetra_meet/blocs/clan/clan_bloc.dart';
import 'package:meetra_meet/blocs/clan/clan_state.dart';
import 'package:meetra_meet/blocs/auth/auth_bloc.dart';
import 'package:meetra_meet/blocs/auth/auth_state.dart';
import 'package:meetra_meet/models/clan_model.dart';
import 'package:meetra_meet/screens/clan/clan_detail_screen.dart';
import 'package:meetra_meet/screens/clan/create_clan_screen.dart';
import 'package:meetra_meet/services/location_service.dart';
import 'package:meetra_meet/utils/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:meetra_meet/screens/leaderboard/leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentCity = "Fetching...";
  bool _isLocationDenied = false;
  
  // Filter states
  String? _selectedCity;
  String? _selectedCategory;
  int _minMembers = 0;
  
  final List<String> _categories = ['Social', 'Professional', 'Hobbies', 'Gaming', 'Fitness', 'Music'];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchLocation();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ClanBloc>().add(LoadMyClansRequested(authState.user.id));
    }
  }

  Future<void> _fetchLocation() async {
    final locationService = LocationService();
    final position = await locationService.getCurrentPosition();
    if (position != null) {
      final address = await locationService.getAddressFromLatLng(position);
      if (address != null && mounted) {
        setState(() {
          _currentCity = address['city'] ?? "Unknown";
          _isLocationDenied = false;
        });
        context.read<ClanBloc>().add(LoadClansByLocation(_currentCity));
      }
    } else {
      if (mounted) {
        setState(() {
          _currentCity = "Location Required";
          _isLocationDenied = true;
        });
        context.read<ClanBloc>().add(const LoadClansByLocation(""));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ClanBloc, ClanState>(
          builder: (context, state) {
            final isLoading = state is ClanLoading || state is ClanInitial;
            
            if (state is ClanLoaded && state.clans.isEmpty && state.myClans.isEmpty && !isLoading) {
              return _buildEmptyState();
            }

            // Dummy data for skeletonizing
            var clans = isLoading ? List.generate(5, (index) => ClanModel(
              id: 'skeleton',
              name: 'Loading Tribe Name',
              description: 'Loading description for this tribe...',
              imageUrl: '',
              adminId: 'skeleton',
              adminName: 'Admin Name',
              memberCount: 0,
              totalEvents: 0,
              isPremium: false,
              categories: ['Social'],
              city: 'Loading...',
              state: '',
              country: '',
              createdAt: DateTime.now(),
            )) : (state is ClanLoaded ? state.clans : <ClanModel>[]);

            // Apply Filters
            if (!isLoading) {
              clans = clans.where((c) {
                final cityMatch = _selectedCity == null || c.city.toLowerCase() == _selectedCity!.toLowerCase();
                final categoryMatch = _selectedCategory == null || c.categories.contains(_selectedCategory);
                final membersMatch = c.memberCount >= _minMembers;
                return cityMatch && categoryMatch && membersMatch;
              }).toList();
            }

            return Skeletonizer(
              enabled: isLoading,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildMyClansSection(state),
                  _buildTrendingSectionFromList(clans),
                  _buildNearbySectionFromList(clans),
                  _buildCTABanner(),
                  SliverToBoxAdapter(child: SizedBox(height: 120.h)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
      sliver: SliverToBoxAdapter(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String name = "Friend";
            String photo = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100";
            
            if (state is AuthAuthenticated) {
              name = state.user.name.split(' ')[0];
              photo = state.user.photoUrl ?? photo;
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundImage: NetworkImage(photo),
                      backgroundColor: Colors.grey[200],
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hey $name 👋', 
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18.sp, 
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          )
                        ),
                        Text('Discover your tribe', 
                          style: TextStyle(fontSize: 12.sp, color: AppColors.onSurfaceVariant)
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildLeaderboardButton(),
                    SizedBox(width: 8.w),
                    _buildLocationPill(),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationPill() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded, color: AppColors.primary, size: 14.w),
          SizedBox(width: 6.w),
          Text(
            _currentCity,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.emoji_events_rounded, color: Colors.amber[700], size: 20.w),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Tribes', style: GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCity = null;
                        _selectedCategory = null;
                        _minMembers = 0;
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text('City', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              _buildFilterChipRow(
                ['All', _currentCity, 'Mumbai', 'Delhi', 'Bangalore'], 
                (val) {
                  setState(() => _selectedCity = val == 'All' ? null : val);
                  setModalState(() {});
                }, 
                _selectedCity ?? 'All'
              ),
              
              SizedBox(height: 24.h),
              Text('Clan Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              SizedBox(height: 8.h),
              _buildFilterChipRow(
                ['All', ..._categories], 
                (val) {
                  setState(() => _selectedCategory = val == 'All' ? null : val);
                  setModalState(() {});
                }, 
                _selectedCategory ?? 'All'
              ),

              SizedBox(height: 24.h),
              Text('Minimum Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              Slider(
                value: _minMembers.toDouble(),
                min: 0,
                max: 1000,
                divisions: 10,
                label: '$_minMembers+',
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _minMembers = val.toInt());
                  setModalState(() {});
                },
              ),
              
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipRow(List<String> options, Function(String) onSelected, String current) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = current == opt;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSelected(opt);
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tribes or events',
                    hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontSize: 14.sp),
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20.w),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: _showFilterDialog,
              child: Container(
                height: 54.h,
                width: 54.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(Icons.tune_rounded, color: Colors.white, size: 20.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyClansSection(ClanState state) {
    final List<ClanModel> myClans = state is ClanLoaded ? state.myClans : [];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Text('My Clans', 
              style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.bold)
            ),
          ),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: myClans.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildCreateClanButton();
                final clan = myClans[index - 1];
                return _buildClanAvatar(clan);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateClanButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClanScreen())),
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        width: 60.r,
        height: 60.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2, style: BorderStyle.none), // Custom dashed needed, using plain for now
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
          ),
          child: Icon(Icons.add_rounded, color: AppColors.primary, size: 24.w),
        ),
      ),
    );
  }

  Widget _buildClanAvatar(ClanModel clan) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClanDetailScreen(clan: clan))),
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 26.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: NetworkImage(clan.imageUrl),
                onBackgroundImageError: (_, __) => const Icon(Icons.groups_rounded, color: AppColors.primary),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(ClanState state) {
    if (state is! ClanLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
            child: Text('Trending Tribes', 
              style: GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.w800)
            ),
          ),
          SizedBox(
            height: 340.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: state.clans.length,
              itemBuilder: (context, index) {
                final clan = state.clans[index];
                return _buildTrendingCard(clan, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(ClanModel clan, int rank) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClanDetailScreen(clan: clan))),
      child: Container(
        width: 260.w,
        margin: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  child: Image.network(
                    clan.imageUrl,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160.h,
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(Icons.image_not_supported_rounded, color: AppColors.primary.withOpacity(0.5)),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text('#$rank', 
                      style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clan.name, 
                    style: GoogleFonts.plusJakartaSans(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.groups_rounded, color: AppColors.onSurfaceVariant, size: 14.w),
                      SizedBox(width: 6.w),
                      Text('${clan.memberCount} members', 
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniAvatars(),
                      BlocBuilder<ClanBloc, ClanState>(
                        builder: (context, state) {
                          bool isJoined = false;
                          if (state is ClanLoaded) {
                            isJoined = state.myClans.any((c) => c.id == clan.id);
                          }
                          
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              gradient: isJoined ? null : const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                              ),
                              color: isJoined ? AppColors.secondaryContainer : null,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(isJoined ? 'Joined' : 'Join', 
                              style: TextStyle(
                                color: isJoined ? AppColors.primary : Colors.white, 
                                fontSize: 12.sp, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          );
                        }
                      ),
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

  Widget _buildMiniAvatars() {
    return SizedBox(
      width: 60.w,
      height: 24.h,
      child: Stack(
        children: List.generate(3, (index) => Positioned(
          left: index * 14.0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 10.r,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${index + 1}&background=E0F2EF&color=1F8A70'),
              onBackgroundImageError: (_, __) {},
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildNearbySection(ClanState state) {
    if (state is! ClanLoaded) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text('Nearby Tribes', 
                style: GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.w800)
              ),
            ),
            ...state.clans.take(3).map((clan) => _buildNearbyCard(clan)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyCard(ClanModel clan) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClanDetailScreen(clan: clan))),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                clan.imageUrl, 
                width: 70.w, 
                height: 70.w, 
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 70.w, height: 70.w, color: AppColors.primary.withOpacity(0.1)),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clan.name, 
                    style: GoogleFonts.plusJakartaSans(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${clan.categories.isNotEmpty ? clan.categories.first : 'Tribe'} • 2.4 km', 
                    style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12.sp)
                  ),
                ],
              ),
            ),
            BlocBuilder<ClanBloc, ClanState>(
              builder: (context, state) {
                bool isJoined = false;
                if (state is ClanLoaded) {
                  isJoined = state.myClans.any((c) => c.id == clan.id);
                }
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isJoined ? AppColors.secondaryContainer : Colors.transparent,
                    border: isJoined ? null : Border.all(color: AppColors.primary, width: 1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(isJoined ? 'Joined' : 'View', 
                    style: TextStyle(color: AppColors.primary, fontSize: 11.sp, fontWeight: FontWeight.bold)
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTABanner() {
    return SliverPadding(
      padding: EdgeInsets.all(20.w),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create your\nown clan', 
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20.sp, 
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                )
              ),
              SizedBox(height: 8.h),
              Text('Build a community around your passion', 
                style: TextStyle(fontSize: 12.sp, color: AppColors.primary.withOpacity(0.7))
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClanScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                child: const Text('Start Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSectionFromList(List<ClanModel> clans) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
            child: Text('Trending Tribes', 
              style: GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.w800)
            ),
          ),
          SizedBox(
            height: 340.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: clans.length,
              itemBuilder: (context, index) {
                return _buildTrendingCard(clans[index], index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySectionFromList(List<ClanModel> clans) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text('Nearby Tribes', 
                style: GoogleFonts.plusJakartaSans(fontSize: 20.sp, fontWeight: FontWeight.w800)
              ),
            ),
            ...clans.take(3).map((clan) => _buildNearbyCard(clan)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(32.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.explore_off_rounded, size: 64.w, color: AppColors.primary),
                ),
                SizedBox(height: 32.h),
                Text('The silence is loud!', 
                  style: GoogleFonts.plusJakartaSans(fontSize: 22.sp, fontWeight: FontWeight.w800)
                ),
                SizedBox(height: 12.h),
                Text('Be the first to start a tribe in $_currentCity. Your people are waiting.', 
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14.sp)
                ),
                SizedBox(height: 40.h),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClanScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    elevation: 0,
                  ),
                  child: const Text('Create a Clan', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
