import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/saved/saved_destinations_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/destination_model.dart';
import '../../widgets/fade_slide.dart';
import 'widgets/ai_recommendations_section.dart';
import 'widgets/category_chip.dart';
import 'widgets/cinematic_footer.dart';
import 'widgets/cinematic_header.dart';
import 'widgets/destination_card.dart';
import 'widgets/events_section.dart';
import 'widgets/live_conditions_section.dart';
import 'widgets/nearby_providers_section.dart';
import 'widgets/section_header.dart';
import 'widgets/service_card.dart';
import 'widgets/tourist_moments_feed.dart';
import 'widgets/travel_advisory_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onSwitchTab, this.navClearance = 0});

  final void Function(int)? onSwitchTab;
  final double navClearance;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategory = 0;

  // ── Categories with icon + colour ─────────────────────────────────────────
  static const _categories = [
    (label: 'Beach',     icon: Icons.beach_access_rounded,    color: Color(0xFF3B82F6)),
    (label: 'Mountain',  icon: Icons.landscape_rounded,       color: Color(0xFF10B981)),
    (label: 'Waterfall', icon: Icons.water_rounded,           color: Color(0xFF6366F1)),
    (label: 'Culture',   icon: Icons.museum_rounded,          color: Color(0xFFF59E0B)),
    (label: 'Food',      icon: Icons.restaurant_rounded,      color: Color(0xFFFB923C)),
    (label: 'Island',    icon: Icons.holiday_village_rounded, color: Color(0xFF14B8A6)),
  ];

  // ── Destinations — first 4 from the full dataset ────────────────────────
  static final _destinations = allBiliranDestinations.take(4).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── 1. Cinematic Hero Header ─────────────────────────────────────
            const SliverToBoxAdapter(
              child: CinematicHeader(),
            ),

            // ── 2. Travel Advisory ───────────────────────────────────────────
            //
            // Safety advisories have been moved from the former Safety tab
            // into this homepage section for a more contextual, always-visible
            // placement. In the prototype phase, advisories are static mock data.
            //
            // FUTURE: Replace _mockAdvisories with real-time API data from
            // PAGASA / OpenWeatherMap, cross-referenced with Biliran destination
            // risk categories, generating dynamic advisory cards automatically.
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                child: FadeSlide(
                  delay: 80.ms,
                  child: SectionHeader(
                    title: 'Travel Advisory',
                    onSeeAll: () {},
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10.h, 0, 0),
                child: const TravelAdvisorySection(),
              ),
            ),

            // ── 3. Categories ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 0),
                child: FadeSlide(
                  delay: 150.ms,
                  child: SectionHeader(
                    title: 'Categories',
                    onSeeAll: () => context.push(AppRouter.categories),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 92.h,
                child: ListView.separated(
                  padding:         EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount:       _categories.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, i) => FadeSlide(
                    delay:       (190 + i * 55).ms,
                    beginOffset: const Offset(0.12, 0),
                    child: CategoryChip(
                      label:      _categories[i].label,
                      icon:       _categories[i].icon,
                      iconColor:  _categories[i].color,
                      isSelected: i == _selectedCategory,
                      onTap:      () => setState(() => _selectedCategory = i),
                    ),
                  ),
                ),
              ),
            ),

            // ── 4a. Continue Exploring — saved destinations ────────────────────
            _ContinueExploringSection(
              destinations: _destinations,
              onTap: (d) => context.push(AppRouter.destinationDetails, extra: d),
            ),

            // ── 4b. Popular Destinations ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 0),
                child: FadeSlide(
                  delay: 260.ms,
                  child: SectionHeader(
                    title: 'Popular Destinations',
                    onSeeAll: () => context.push(AppRouter.destinations),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210.h,
                child: ListView.separated(
                  padding:         EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount:       _destinations.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, i) {
                    final d = _destinations[i];
                    return DestinationCard(
                      title:          d.title,
                      location:       d.municipality,
                      rating:         d.rating,
                      imageAsset:     d.imageAsset,
                      index:          i,
                      destinationId:  d.id,
                      heroTag:        d.heroTag,
                      onTap:          () => context.push(AppRouter.destinationDetails, extra: d),
                    );
                  },
                ),
              ),
            ),

            // ── 5. Local Services ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 0),
                child: FadeSlide(
                  delay: 340.ms,
                  child: SectionHeader(
                    title: 'Local Services',
                    onSeeAll: () {},
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: FadeSlide(
                  delay: 370.ms,
                  child: const ServicesSection(),
                ),
              ),
            ),

            // ── 6. Explore Map ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 0),
                child: FadeSlide(
                  delay: 420.ms,
                  child: SectionHeader(title: 'Explore Map'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
                child: FadeSlide(
                  delay: 450.ms,
                  child: _ExploreMapCard(
                    onOpen: () => widget.onSwitchTab?.call(2),
                  ),
                ),
              ),
            ),

            // ── 7. Live Travel Conditions ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 0),
                child: FadeSlide(
                  delay: 500.ms,
                  child: SectionHeader(
                    title: 'Live Travel Conditions',
                    onSeeAll: () {},
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeSlide(
                delay: 520.ms,
                child: const LiveConditionsSection(),
              ),
            ),

            // ── 8. Nearby Verified Providers ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 0),
                child: FadeSlide(
                  delay: 560.ms,
                  child: SectionHeader(
                    title: 'Nearby Verified Providers',
                    onSeeAll: () {},
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeSlide(
                delay: 580.ms,
                child: const NearbyProvidersSection(),
              ),
            ),

            // ── 9. AI Recommendations ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 0),
                child: FadeSlide(
                  delay: 600.ms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Smart Route Suggestions',
                        onSeeAll: () {},
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0369A1), Color(0xFF0D9488)],
                              ),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.route_rounded,
                                    color: Colors.white, size: 9.sp),
                                SizedBox(width: 4.w),
                                Text('BiliRoute Intelligence',
                                    style: TextStyle(
                                      color:      Colors.white,
                                      fontSize:   9.sp,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                          ).animate().shimmer(duration: 2200.ms, delay: 800.ms),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeSlide(
                delay: 620.ms,
                child: const AiRecommendationsSection(),
              ),
            ),

            // ── 10. Upcoming Events & Festivals ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 0),
                child: FadeSlide(
                  delay: 650.ms,
                  child: SectionHeader(
                    title: 'Upcoming Events',
                    onSeeAll: () {},
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeSlide(
                delay: 670.ms,
                child: const EventsSection(),
              ),
            ),

            // ── 11. Tourist Moments Feed ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 0),
                child: FadeSlide(
                  delay: 700.ms,
                  child: SectionHeader(
                    title: 'Tourist Moments',
                    onSeeAll: () {},
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeSlide(
                delay: 720.ms,
                child: const TouristMomentsFeed(),
              ),
            ),

            // ── 12. Cinematic Footer ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 28.h),
                child: CinematicFooter(
                  onExploreMap: () => widget.onSwitchTab?.call(2),
                  onPlanTrip:   () => widget.onSwitchTab?.call(1),
                ),
              ),
            ),

            // ── Bottom clearance ───────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(height: widget.navClearance),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Explore Map card ──────────────────────────────────────────────────────────

class _ExploreMapCard extends StatelessWidget {
  const _ExploreMapCard({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:     150.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Map-style gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [Color(0xFFD1FAE5), Color(0xFFBFDBFE)],
                ),
              ),
            ),

            // Decorative map pin icon (right side)
            Positioned(
              right: -10.w,
              top:   -10.h,
              child: Icon(Icons.map_rounded,
                  size: 120.sp,
                  color: Colors.white.withValues(alpha: 0.35)),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.center,
                children: [
                  Text(
                    'Explore Biliran Island',
                    style: TextStyle(
                      fontSize:   17.sp,
                      fontWeight: FontWeight.w800,
                      color:      AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'Find destinations, routes and important\nlocations on the map.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:    AppColors.textSecondary,
                      height:   1.45,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: onOpen,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color:        AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined,
                              color: Colors.white, size: 15.sp),
                          SizedBox(width: 7.w),
                          Text(
                            'Open Map',
                            style: TextStyle(
                              color:      Colors.white,
                              fontSize:   12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContinueExploringSection — Saved destinations horizontal strip
// Only rendered when the user has ≥1 saved destination.
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueExploringSection extends StatelessWidget {
  const _ContinueExploringSection({
    required this.destinations,
    required this.onTap,
  });

  final List<DestinationItem>             destinations;
  final void Function(DestinationItem d)  onTap;

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedDestinationsNotifier>();
    if (saved.savedIds.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final savedDests = allBiliranDestinations
        .where((d) => saved.isSaved(d.id))
        .toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 0),
            child: FadeSlide(
              delay: 240.ms,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue Exploring',
                          style: TextStyle(
                            fontSize:   17.sp,
                            fontWeight: FontWeight.w800,
                            color:      Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Your saved destinations',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color:    AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRouter.savedDestinations),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        fontSize:   13.sp,
                        fontWeight: FontWeight.w600,
                        color:      AppColors.royalBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 210.h,
            child: ListView.separated(
              padding:          EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              scrollDirection:  Axis.horizontal,
              itemCount:        savedDests.length,
              separatorBuilder: (_, _) => SizedBox(width: 12.w),
              itemBuilder: (context, i) {
                final d = savedDests[i];
                return DestinationCard(
                  title:         d.title,
                  location:      d.municipality,
                  rating:        d.rating,
                  imageAsset:    d.imageAsset,
                  index:         i,
                  destinationId: d.id,
                  heroTag:       '${d.heroTag}_saved',
                  onTap:         () => onTap(d),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
