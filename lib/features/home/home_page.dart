import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/saved/saved_destinations_notifier.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/destination_model.dart';
import '../../l10n/app_localizations.dart';
import '../destinations/repositories/destination_repository.dart';
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
  int    _selectedCategory = 0;
  String _searchQuery      = '';

  // ── Categories with icon + colour ─────────────────────────────────────────
  List<(String label, IconData icon, Color color)> _getCategories(AppLocalizations l10n) => [
    (l10n.categoryBeach,     Icons.beach_access_rounded,    const Color(0xFF3B82F6)),
    (l10n.categoryMountain,  Icons.landscape_rounded,       const Color(0xFF10B981)),
    (l10n.categoryWaterfall, Icons.water_rounded,           const Color(0xFF6366F1)),
    (l10n.categoryCulture,   Icons.museum_rounded,          const Color(0xFFF59E0B)),
    (l10n.categoryFood,      Icons.restaurant_rounded,      const Color(0xFFFB923C)),
    (l10n.categoryIsland,    Icons.holiday_village_rounded, const Color(0xFF14B8A6)),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n            = AppLocalizations.of(context)!;
    final categories      = _getCategories(l10n);
    final destinationRepo = context.watch<TouristDestinationRepository>();
    final allDestinations = destinationRepo.destinations.isNotEmpty
        ? destinationRepo.destinations
        : allBiliranDestinations;

    // Client-side search filter — voice text flows through the same pipeline
    final destinations = _searchQuery.isEmpty
        ? allDestinations
        : allDestinations.where((d) {
            final q = _searchQuery.toLowerCase();
            return d.title.toLowerCase().contains(q) ||
                   d.municipality.toLowerCase().contains(q) ||
                   d.description.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── 1. Cinematic Hero Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: CinematicHeader(
                onQueryChanged: (q) => setState(() => _searchQuery = q),
              ),
            ),

            // ── 2. Live Conditions Floating Bar ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: const LiveConditionsSection(),
              ),
            ),

            // ── 2b. Travel Advisories ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: const TravelAdvisorySection(),
              ),
            ),

            // ── 3. Categories Horizontal Bar ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                child: FadeSlide(
                  delay: 150.ms,
                  child: SectionHeader(
                    title: l10n.sectionCategories,
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
                  itemCount:       categories.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, i) => FadeSlide(
                    delay:       (190 + i * 55).ms,
                    beginOffset: const Offset(0.12, 0),
                    child: CategoryChip(
                      label:      categories[i].$1,
                      icon:       categories[i].$2,
                      iconColor:  categories[i].$3,
                      isSelected: i == _selectedCategory,
                      onTap:      () => setState(() => _selectedCategory = i),
                    ),
                  ),
                ),
              ),
            ),

            // ── 4a. Continue Exploring — saved destinations ────────────────────
            _ContinueExploringSection(
              destinations: destinations,
              onTap: (d) => context.push(AppRouter.destinationDetails, extra: d),
            ),

            // ── 4b. Popular Destinations ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 0),
                child: FadeSlide(
                  delay: 260.ms,
                  child: SectionHeader(
                    title: destinations.isEmpty && _searchQuery.isNotEmpty
                        ? l10n.noResultsFound
                        : l10n.sectionPopularDestinations,
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
                  itemCount:       destinations.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, i) {
                    final d = destinations[i];
                    return DestinationCard(
                      title:          d.localizedTitle(l10n.localeName),
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
                    title: l10n.sectionLocalServices,
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
                  child: SectionHeader(title: l10n.sectionExploreMap),
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
                    title: l10n.sectionLiveTravelConditions,
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
                    title: l10n.sectionNearbyProviders,
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
                        title: l10n.sectionSmartRouteSuggestions,
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
                    title: l10n.sectionUpcomingEvents,
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
                    title: l10n.sectionTouristMoments,
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
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.exploreBiliranIsland,
                    style: TextStyle(
                      fontSize:   17.sp,
                      fontWeight: FontWeight.w800,
                      color:      AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    l10n.exploreBiliranDesc,
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
                            l10n.openMap,
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

    final savedDests = destinations
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
              child: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.sectionContinueExploring,
                              style: TextStyle(
                                fontSize:   17.sp,
                                fontWeight: FontWeight.w800,
                                color:      Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              l10n.yourSavedDestinations,
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
                          l10n.seeAll,
                          style: TextStyle(
                            fontSize:   13.sp,
                            fontWeight: FontWeight.w600,
                            color:      AppColors.royalBlue,
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
                final d    = savedDests[i];
                final l10n = AppLocalizations.of(context)!;
                return DestinationCard(
                  title:         d.localizedTitle(l10n.localeName),
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
