import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/transitions/transition_data.dart';
import '../../../data/models/destination_model.dart';
import '../../../data/providers/biliran_providers.dart';
import '../../../data/providers/service_provider.dart';
import '../../../widgets/ambient/ambient_particles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Destination Details Screen
// ─────────────────────────────────────────────────────────────────────────────

class DestinationDetailsScreen extends StatefulWidget {
  const DestinationDetailsScreen({super.key, required this.item});

  final DestinationItem item;

  @override
  State<DestinationDetailsScreen> createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen>
    with TickerProviderStateMixin {

  late final AnimationController _pulseCtrl;
  late final AnimationController _shimmerCtrl;
  final _pageCtrl = PageController();
  int  _currentPage  = 0;
  bool _aboutExpanded = false;
  bool _saved = false;

  DestinationItem get item => widget.item;

  // Gallery = primary image + extras
  List<String> get _gallery => item.galleryAssets;

  // Providers relevant to this destination
  List<ServiceProvider> get _providers {
    return BiliranProviders.verified
        .where((p) => p.routeSegment.toLowerCase().contains(
              item.title.split(' ').first.toLowerCase(),
            ))
        .take(4)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: 2.seconds)
      ..repeat(reverse: true);
    _shimmerCtrl = AnimationController(vsync: this, duration: 1.8.seconds)
      ..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundStart,
        body: Stack(
          children: [
            // ── Scrollable content ─────────────────────────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Collapsing hero header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HeroHeaderDelegate(
                    item:      item,
                    saved:     _saved,
                    onSave:    () => setState(() => _saved = !_saved),
                    onBack:    () => context.pop(),
                    maxH:      360.h,
                    minH:      kToolbarHeight + MediaQuery.of(context).padding.top,
                    pulseCtrl: _pulseCtrl,
                  ),
                ),

                // 2. Quick stats row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                    child: _QuickStatsRow(item: item),
                  ),
                ),

                // 3. About section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                    child: _AboutSection(
                      item:     item,
                      expanded: _aboutExpanded,
                      onToggle: () => setState(() => _aboutExpanded = !_aboutExpanded),
                    ),
                  ),
                ),

                // 4. Gallery
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: _GallerySection(
                      images:      _gallery,
                      pageCtrl:    _pageCtrl,
                      currentPage: _currentPage,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      onTapImage: (index) => _openFullscreenGallery(index),
                    ),
                  ),
                ),

                // 5. Entrance fees & packages
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                    child: _FeesAndPackagesSection(item: item, shimmerCtrl: _shimmerCtrl),
                  ),
                ),

                // 6. Verified providers
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                    child: _ProvidersSection(providers: _providers, item: item),
                  ),
                ),

                // 7. Mini map
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                    child: _MiniMapSection(item: item, pulseCtrl: _pulseCtrl),
                  ),
                ),

                // 8. Route recommendations
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                    child: _RouteRecommendationsSection(item: item),
                  ),
                ),

                // 9. Safety tips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                    child: _SafetySection(item: item),
                  ),
                ),

                // Bottom clearance for sticky bar
                SliverToBoxAdapter(child: SizedBox(height: 110.h)),
              ],
            ),

            // ── Sticky bottom action bar ───────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _BottomBar(item: item, pulseCtrl: _pulseCtrl),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fullscreen gallery modal ───────────────────────────────────────────────

  void _openFullscreenGallery(int startIndex) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      builder: (_) => _FullscreenGallery(images: _gallery, initialIndex: startIndex),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapsing Hero Header Delegate
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeroHeaderDelegate({
    required this.item,
    required this.saved,
    required this.onSave,
    required this.onBack,
    required this.maxH,
    required this.minH,
    required this.pulseCtrl,
  });

  final DestinationItem     item;
  final bool                saved;
  final VoidCallback         onSave;
  final VoidCallback         onBack;
  final double               maxH;
  final double               minH;
  final AnimationController  pulseCtrl;

  @override double get maxExtent => maxH;
  @override double get minExtent => minH;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxH - minH)).clamp(0.0, 1.0);
    final imageParallax = -shrinkOffset * 0.35;
    final safeTop = MediaQuery.of(context).padding.top;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [

          // ── Parallax hero image ─────────────────────────────────────────
          Positioned(
            top:   imageParallax,
            left:  0, right: 0,
            height: maxH + 60.h,
            child: Hero(
              tag: item.heroTag,
              child: Image.asset(
                item.imageAsset,
                fit:          BoxFit.cover,
                alignment:    Alignment.center,
                errorBuilder: (_, e, s) => Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                ),
              ),
            ),
          ),

          // ── Dark overlay ───────────────────────────────────────────────
          Container(color: Colors.black.withValues(alpha: 0.38 + progress * 0.35)),

          // ── Bottom gradient ────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 180.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                ),
              ),
            ),
          ),

          // ── Ambient particles (fade out as header collapses) ───────────
          if (progress < 0.6)
            Opacity(
              opacity: (1 - progress / 0.6).clamp(0.0, 1.0),
              child: const AmbientParticles(
                count:     12,
                color:     Colors.white,
                maxRadius: 2.0,
                speed:     0.3,
                opacity:   0.25,
                seed:      99,
              ),
            ),

          // ── Back + Save buttons ────────────────────────────────────────
          Positioned(
            top:   safeTop + 10.h,
            left:  16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40.r, height: 40.r,
                    decoration: BoxDecoration(
                      color:        Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12.r),
                      border:       Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18.sp),
                  ),
                ),
                // Save / favourite
                GestureDetector(
                  onTap: onSave,
                  child: AnimatedContainer(
                    duration: 250.ms,
                    width: 40.r, height: 40.r,
                    decoration: BoxDecoration(
                      color:        saved
                          ? Colors.red.withValues(alpha: 0.85)
                          : Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12.r),
                      border:       Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Icon(
                      saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: Colors.white, size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Destination info (fades out when collapsed) ───────────────
          Positioned(
            bottom: 20.h, left: 20.w, right: 20.w,
            child: Opacity(
              opacity: (1 - progress * 2.5).clamp(0.0, 1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color:        item.categoryColor.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Name
                  Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Location + rating row
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, color: Colors.white70, size: 13.sp),
                      SizedBox(width: 3.w),
                      Text(
                        item.location,
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      // Star rating
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color:        Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(99),
                          border:       Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 14),
                            SizedBox(width: 3.w),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // BTO Verified badge
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, color: const Color(0xFF34D399), size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Verified by Biliran Tourism Office',
                        style: TextStyle(color: const Color(0xFF34D399), fontSize: 11.sp, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsed title (appears when scrolled) ────────────────────
          if (progress > 0.75)
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: minH,
              child: Container(
                color: AppColors.primary,
                padding: EdgeInsets.only(top: safeTop),
                child: Row(
                  children: [
                    SizedBox(width: 56.w + 16.w),
                    Expanded(
                      child: Text(
                        item.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: 56.w),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_HeroHeaderDelegate old) =>
      old.saved != saved || old.progress != progress;

  double get progress => 0; // used only in shouldRebuild placeholder
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Stats Row — glassmorphism pills
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.item});
  final DestinationItem item;

  @override
  Widget build(BuildContext context) {
    final stats = [
      (icon: Icons.payments_rounded,       label: 'Fare',        value: '₱${item.estimatedFare}', color: AppColors.primary),
      (icon: Icons.schedule_rounded,       label: 'Travel Time', value: item.travelTime,          color: AppColors.accentSoft),
      (icon: Icons.wb_sunny_rounded,       label: 'Best Season', value: item.bestSeason,          color: const Color(0xFFF59E0B)),
      (icon: Icons.terrain_rounded,        label: 'Difficulty',  value: item.difficulty,          color: item.difficultyColor),
      (icon: Icons.signal_cellular_alt_rounded, label: 'Signal', value: item.signal,              color: const Color(0xFF6366F1)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'At a Glance', icon: Icons.info_outline_rounded, animDelay: 0),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: stats.asMap().entries.map((e) {
              final s = e.value;
              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: _StatPill(
                  icon:      s.icon,
                  label:     s.label,
                  value:     s.value,
                  color:     s.color,
                  animDelay: (e.key * 60).ms,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.animDelay,
  });
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  final Duration animDelay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.10), blurRadius: 12, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28.r, height: 28.r,
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 15.sp),
              ),
              SizedBox(width: 8.w),
              Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize:   13.sp,
              fontWeight: FontWeight.w800,
              color:      AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate(delay: animDelay).fade(duration: 400.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// About Section — expandable description + tips
// ─────────────────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.item, required this.expanded, required this.onToggle});
  final DestinationItem item;
  final bool            expanded;
  final VoidCallback    onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  width: 34.r, height: 34.r,
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(Icons.info_rounded, color: Colors.white, size: 16.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(child: Text('About ${item.title}',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              item.description,
              maxLines: expanded ? null : 3,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.6),
            ),
          ),

          // Expand/collapse toggle
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
              child: Row(
                children: [
                  Text(expanded ? 'Show less' : 'Read more',
                      style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w700)),
                  Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary, size: 16.sp),
                ],
              ),
            ),
          ),

          if (expanded) ...[
            _BulletSection(title: 'Things To Do',   icon: Icons.check_circle_outline_rounded, color: AppColors.accentSoft, items: item.thingsToDo),
            _BulletSection(title: 'What To Bring',  icon: Icons.backpack_rounded,             color: AppColors.info,       items: item.whatToBring),
          ],

          SizedBox(height: 16.h),
        ],
      ),
    ).animate(delay: 100.ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({required this.title, required this.icon, required this.color, required this.items});
  final String       title;
  final IconData     icon;
  final Color        color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 15.sp),
            SizedBox(width: 6.w),
            Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
          SizedBox(height: 8.h),
          ...items.map((t) => Padding(
            padding: EdgeInsets.only(bottom: 5.h),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 8.w),
                child: Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              ),
              Expanded(child: Text(t, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, height: 1.5))),
            ]),
          )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gallery Section — horizontal PageView + thumbnail strip
// ─────────────────────────────────────────────────────────────────────────────

class _GallerySection extends StatelessWidget {
  const _GallerySection({
    required this.images,
    required this.pageCtrl,
    required this.currentPage,
    required this.onPageChanged,
    required this.onTapImage,
  });
  final List<String>        images;
  final PageController       pageCtrl;
  final int                  currentPage;
  final ValueChanged<int>    onPageChanged;
  final ValueChanged<int>    onTapImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: _SectionTitle(title: 'Photo Gallery', icon: Icons.photo_library_rounded, animDelay: 150),
        ),

        // Main gallery viewer
        SizedBox(
          height: 220.h,
          child: PageView.builder(
            controller:  pageCtrl,
            onPageChanged: onPageChanged,
            itemCount:   images.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => onTapImage(i),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(images[i], fit: BoxFit.cover,
                        errorBuilder: (_, e, s) => Container(
                          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                          child: const Icon(Icons.image_rounded, color: Colors.white54, size: 40),
                        )),
                    // Fullscreen hint
                    Positioned(
                      bottom: 12.h, right: 12.w,
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16.sp),
                      ),
                    ),
                    // Image counter
                    Positioned(
                      bottom: 12.h, left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text('${i + 1} / ${images.length}',
                            style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Page dots
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (i) => AnimatedContainer(
            duration: 250.ms,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width:  currentPage == i ? 20.w : 7.w,
            height: 6.h,
            decoration: BoxDecoration(
              color:        currentPage == i ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(99),
            ),
          )),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fullscreen Gallery Modal
// ─────────────────────────────────────────────────────────────────────────────

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({required this.images, required this.initialIndex});
  final List<String> images;
  final int          initialIndex;
  @override State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late int _current;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl    = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            PageView.builder(
              controller:    _ctrl,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount:     widget.images.length,
              itemBuilder:   (_, i) => InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.asset(widget.images[i], fit: BoxFit.contain,
                    errorBuilder: (_, e, s) => const Icon(Icons.image_not_supported_rounded, color: Colors.white54, size: 60)),
              ),
            ),
            // Close button
            Positioned(
              top:   50.h, right: 16.w,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(99)),
                  child: Icon(Icons.close_rounded, color: Colors.white, size: 22.sp),
                ),
              ),
            ),
            // Counter
            Positioned(
              top: 55.h, left: 0, right: 0,
              child: Center(child: Text('${_current + 1} / ${widget.images.length}',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fees & Packages Section
// ─────────────────────────────────────────────────────────────────────────────

class _FeesAndPackagesSection extends StatelessWidget {
  const _FeesAndPackagesSection({required this.item, required this.shimmerCtrl});
  final DestinationItem     item;
  final AnimationController shimmerCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Entrance Fees & Packages', icon: Icons.confirmation_number_rounded, animDelay: 200),
        SizedBox(height: 14.h),

        // Fee breakdown card
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: [AppColors.primary, const Color(0xFF0369A1)],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              _FeeRow(label: 'Entrance Fee (Adult)',  value: '₱${item.entranceFee}'),
              if (item.cottageFee != null) _FeeRow(label: 'Cottage Rental',  value: '₱${item.cottageFee}'),
              _FeeRow(label: 'Environmental Fee',     value: '₱${item.envFee}'),
              Divider(color: Colors.white.withValues(alpha: 0.2), height: 20),
              Row(children: [
                Icon(Icons.info_outline_rounded, color: Colors.white60, size: 12.sp),
                SizedBox(width: 6.w),
                Expanded(child: Text('Fees are official LGU/BTO rates. Subject to change.',
                    style: TextStyle(color: Colors.white60, fontSize: 10.sp))),
              ]),
            ],
          ),
        ).animate(delay: 220.ms).fade().slideY(begin: 0.06, end: 0),

        SizedBox(height: 14.h),

        // Tour packages
        ...item.packages.asMap().entries.map((e) =>
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _PackageCard(pkg: e.value, animIndex: e.key),
          ),
        ),
      ],
    );
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5.sp)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.pkg, required this.animIndex});
  final TourPackage pkg;
  final int         animIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border:       Border.all(
          color:     pkg.isPopular ? AppColors.accentSoft.withValues(alpha: 0.4) : AppColors.divider,
          width:     pkg.isPopular ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(pkg.name, style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),
              if (pkg.isPopular)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    gradient: AppColors.successGradient,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text('Popular', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(pkg.duration, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5.sp)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w, runSpacing: 6.h,
            children: pkg.inclusions.map((inc) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundStart,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text('✓ $inc', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            )).toList(),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₱${pkg.price}',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColors.primary)),
              Text('per person', style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5.sp)),
            ],
          ),
        ],
      ),
    ).animate(delay: (240 + animIndex * 70).ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verified Providers Section
// ─────────────────────────────────────────────────────────────────────────────

class _ProvidersSection extends StatelessWidget {
  const _ProvidersSection({required this.providers, required this.item});
  final List<ServiceProvider> providers;
  final DestinationItem       item;

  @override
  Widget build(BuildContext context) {
    // Fallback: show generic boat operators if no match
    final display = providers.isNotEmpty
        ? providers
        : BiliranProviders.byType(ProviderType.boatOperator).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Verified Providers', icon: Icons.verified_rounded, animDelay: 300),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color:        AppColors.accentSoft.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border:       Border.all(color: AppColors.accentSoft.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(Icons.shield_rounded, color: AppColors.accentSoft, size: 14.sp),
            SizedBox(width: 6.w),
            Expanded(child: Text('All providers verified by Biliran Tourism Office',
                style: TextStyle(fontSize: 11.sp, color: AppColors.accentSoft, fontWeight: FontWeight.w600))),
          ]),
        ),
        SizedBox(height: 12.h),
        ...display.asMap().entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _ProviderCard(provider: e.value, animIndex: e.key),
        )),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider, required this.animIndex});
  final ServiceProvider provider;
  final int             animIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46.r, height: 46.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [provider.type.color.withValues(alpha: 0.8), provider.type.color]),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(provider.type.icon, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(provider.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  if (provider.isVerified)
                    Icon(Icons.verified_rounded, color: const Color(0xFF3B82F6), size: 14.sp),
                ]),
                SizedBox(height: 3.h),
                Text(provider.type.label,
                    style: TextStyle(fontSize: 10.5.sp, color: provider.type.color, fontWeight: FontWeight.w600)),
                SizedBox(height: 3.h),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 12),
                  SizedBox(width: 2.w),
                  Text(provider.rating?.toStringAsFixed(1) ?? '—',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                  if (provider.availability != null) ...[
                    SizedBox(width: 8.w),
                    Expanded(child: Text(provider.availability!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary))),
                  ],
                ]),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Call button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 38.r, height: 38.r,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.phone_rounded, color: Colors.white, size: 16.sp),
            ),
          ),
        ],
      ),
    ).animate(delay: (300 + animIndex * 60).ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location & Navigation Section — working map + info card
// ─────────────────────────────────────────────────────────────────────────────

// Default prototype origin: Naval Terminal (land departure hub)
const _kNavalTerminal = LatLng(11.5602, 124.3973);
const _kNavalTerminalName = 'Naval Terminal';

class _MiniMapSection extends StatefulWidget {
  const _MiniMapSection({required this.item, required this.pulseCtrl});
  final DestinationItem     item;
  final AnimationController pulseCtrl;
  @override State<_MiniMapSection> createState() => _MiniMapSectionState();
}

class _MiniMapSectionState extends State<_MiniMapSection> {
  final Completer<GoogleMapController> _mapCompleter = Completer();

  DestinationItem get item => widget.item;

  // Destination LatLng read from the verified model
  LatLng get _destLoc => LatLng(item.lat, item.lng);

  @override
  void dispose() {
    _mapCompleter.future.then((ctrl) => ctrl.dispose());
    super.dispose();
  }

  // Fit camera to show both origin + destination with padding
  Future<void> _fitBounds(GoogleMapController ctrl) async {
    final bounds = LatLngBounds(
      southwest: LatLng(
        _kNavalTerminal.latitude  < _destLoc.latitude  ? _kNavalTerminal.latitude  : _destLoc.latitude,
        _kNavalTerminal.longitude < _destLoc.longitude ? _kNavalTerminal.longitude : _destLoc.longitude,
      ),
      northeast: LatLng(
        _kNavalTerminal.latitude  > _destLoc.latitude  ? _kNavalTerminal.latitude  : _destLoc.latitude,
        _kNavalTerminal.longitude > _destLoc.longitude ? _kNavalTerminal.longitude : _destLoc.longitude,
      ),
    );
    // Small delay to let the map initialise before animating
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      await ctrl.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 52),
      );
    }
  }

  void _navigateToRouteSelection(BuildContext context) {
    context.push(
      AppRouter.routeSelection,
      extra: TransitionPayload(
        destinationName: item.title,
        heroTag:         item.heroTag,
        imageAsset:      item.imageAsset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title:      'Location & Navigation',
          icon:       Icons.navigation_rounded,
          animDelay:  350,
        ),
        SizedBox(height: 14.h),

        // ── Embedded Google Map ──────────────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            height: 240.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [BoxShadow(
                color:      Colors.black.withValues(alpha: 0.16),
                blurRadius: 18,
                offset:     const Offset(0, 6),
              )],
            ),
            child: Stack(
              children: [

                // Google Maps — all coordinates consumed from item model
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      (_kNavalTerminal.latitude  + _destLoc.latitude)  / 2,
                      (_kNavalTerminal.longitude + _destLoc.longitude) / 2,
                    ),
                    zoom: 8.8,
                  ),
                  onMapCreated: (ctrl) {
                    if (!_mapCompleter.isCompleted) _mapCompleter.complete(ctrl);
                    _fitBounds(ctrl);
                  },
                  mapType:                 MapType.hybrid,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled:     false,
                  compassEnabled:          false,
                  rotateGesturesEnabled:   false,

                  markers: {
                    // ① Naval Terminal — origin marker (blue)
                    Marker(
                      markerId:   const MarkerId('origin'),
                      position:   _kNavalTerminal,
                      icon:       BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueAzure),
                      infoWindow: const InfoWindow(
                        title:   '🚐 Naval Terminal',
                        snippet: 'Prototype origin point',
                      ),
                    ),
                    // ② Destination — field-verified if isFieldVerified
                    Marker(
                      markerId:   const MarkerId('destination'),
                      position:   _destLoc,
                      icon:       BitmapDescriptor.defaultMarkerWithHue(
                                    item.isFieldVerified
                                        ? BitmapDescriptor.hueGreen
                                        : BitmapDescriptor.hueRed),
                      infoWindow: InfoWindow(
                        title:   item.title,
                        snippet: item.isFieldVerified
                            ? '✅ Field-verified coordinates'
                            : 'Estimated location',
                      ),
                    ),
                  },

                  polylines: {
                    // Route preview polyline (Naval → Destination)
                    Polyline(
                      polylineId: const PolylineId('preview_route'),
                      points:     [_kNavalTerminal, _destLoc],
                      color:      const Color(0xFF60A5FA),
                      width:      3,
                      patterns:   [PatternItem.dash(22), PatternItem.gap(14)],
                    ),
                  },

                  circles: {
                    // Pulsing origin circle
                    Circle(
                      circleId:    const CircleId('origin_pulse'),
                      center:      _kNavalTerminal,
                      radius:      700,
                      fillColor:   const Color(0x223B82F6),
                      strokeColor: const Color(0xFF3B82F6),
                      strokeWidth: 2,
                    ),
                    // Destination glow
                    Circle(
                      circleId:    const CircleId('dest_glow'),
                      center:      _destLoc,
                      radius:      500,
                      fillColor:   item.isFieldVerified
                          ? const Color(0x2210B981)
                          : const Color(0x22EF4444),
                      strokeColor: item.isFieldVerified
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      strokeWidth: 2,
                    ),
                  },
                ),

                // ── Route label chip (top-left) ──────────────────────────
                Positioned(
                  top: 12.h, left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color:        Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(10.r),
                      border:       Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.route_rounded, color: const Color(0xFF60A5FA), size: 12.sp),
                      SizedBox(width: 5.w),
                      Text(
                        '$_kNavalTerminalName → ${item.title.split(' ').first}',
                        style: TextStyle(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.w600),
                      ),
                    ]),
                  ),
                ),

                // ── Travel time chip (top-right) ─────────────────────────
                Positioned(
                  top: 12.h, right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color:        Colors.black.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.schedule_rounded, color: const Color(0xFF34D399), size: 12.sp),
                      SizedBox(width: 4.w),
                      Text(
                        item.travelTime,
                        style: TextStyle(color: const Color(0xFF34D399), fontSize: 10.5.sp, fontWeight: FontWeight.w700),
                      ),
                    ]),
                  ),
                ),

                // ── Field-verified badge (bottom-left, only for verified) ─
                if (item.isFieldVerified)
                  Positioned(
                    bottom: 12.h, left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color:        const Color(0xFF064E3B).withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(8.r),
                        border:       Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.verified_rounded, color: Color(0xFF34D399), size: 11),
                        SizedBox(width: 4.w),
                        Text(
                          'Field Verified GPS',
                          style: TextStyle(color: const Color(0xFF34D399), fontSize: 9.5.sp, fontWeight: FontWeight.w700),
                        ),
                      ]),
                    ),
                  ),

                // ── Navigate CTA (bottom-right) ──────────────────────────
                Positioned(
                  bottom: 12.h, right: 12.w,
                  child: GestureDetector(
                    onTap: () => _navigateToRouteSelection(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        gradient:     AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow:    [BoxShadow(
                          color:      AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 10,
                        )],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.navigation_rounded, color: Colors.white, size: 13.sp),
                        SizedBox(width: 5.w),
                        Text('Navigate', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: 360.ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0),

        SizedBox(height: 14.h),

        // ── Navigation Info Card ─────────────────────────────────────────────
        _NavigationInfoCard(item: item, onFindRoute: () => _navigateToRouteSelection(context)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Info Card — route summary below the mini-map
// ─────────────────────────────────────────────────────────────────────────────

class _NavigationInfoCard extends StatelessWidget {
  const _NavigationInfoCard({required this.item, required this.onFindRoute});
  final DestinationItem item;
  final VoidCallback    onFindRoute;

  @override
  Widget build(BuildContext context) {
    final travelModes = item.recommendedRoutes.isNotEmpty
        ? item.recommendedRoutes.first.steps.map((s) => s.mode).join(' → ')
        : 'Multi-modal';

    final hasSeaRoute = item.recommendedRoutes.isNotEmpty &&
        item.recommendedRoutes.first.steps.any((s) => s.isSeaRoute);

    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:  Alignment.centerLeft,
                end:    Alignment.centerRight,
                colors: [AppColors.primary.withValues(alpha: 0.07), Colors.transparent],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(children: [
              Container(
                width: 32.r, height: 32.r,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(9.r)),
                child: Icon(Icons.alt_route_rounded, color: Colors.white, size: 16.sp),
              ),
              SizedBox(width: 10.w),
              Text('Navigation Summary',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const Spacer(),
              if (item.isFieldVerified)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color:        const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6.r),
                    border:       Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 10),
                    SizedBox(width: 3.w),
                    Text('Field Verified', style: TextStyle(color: const Color(0xFF059669), fontSize: 9.sp, fontWeight: FontWeight.w700)),
                  ]),
                ),
            ]),
          ),

          // Info grid
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
            child: Column(
              children: [
                _NavInfoRow(
                  icon:  Icons.trip_origin_rounded,
                  color: const Color(0xFF3B82F6),
                  label: 'From',
                  value: _kNavalTerminalName,
                ),
                _NavInfoRow(
                  icon:  Icons.location_on_rounded,
                  color: AppColors.accentSoft,
                  label: 'Destination',
                  value: item.title,
                ),
                _NavInfoRow(
                  icon:  Icons.schedule_rounded,
                  color: const Color(0xFFF59E0B),
                  label: 'Estimated Travel Time',
                  value: item.travelTime,
                ),
                _NavInfoRow(
                  icon:  Icons.commute_rounded,
                  color: AppColors.primary,
                  label: 'Travel Mode',
                  value: travelModes,
                ),
                _NavInfoRow(
                  icon:  hasSeaRoute ? Icons.waves_rounded : Icons.terrain_rounded,
                  color: hasSeaRoute ? const Color(0xFF0EA5E9) : const Color(0xFF10B981),
                  label: 'Route Type',
                  value: hasSeaRoute ? 'Land + Sea Route' : 'Land Route',
                ),
                Divider(height: 18.h, color: AppColors.divider),
                // Coordinates row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28.r, height: 28.r,
                      decoration: BoxDecoration(
                        color:        (item.isFieldVerified ? const Color(0xFF10B981) : AppColors.textSecondary)
                                          .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      child: Icon(
                        Icons.gps_fixed_rounded,
                        color: item.isFieldVerified ? const Color(0xFF10B981) : AppColors.textSecondary,
                        size:  13.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('GPS Coordinates',
                                style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            if (item.isFieldVerified) ...[
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color:        const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text('Primary Data',
                                    style: TextStyle(color: const Color(0xFF059669), fontSize: 8.sp, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ]),
                          SizedBox(height: 3.h),
                          Text(
                            '${item.lat.toStringAsFixed(8)}, ${item.lng.toStringAsFixed(8)}',
                            style: TextStyle(
                              fontSize:   11.5.sp,
                              fontWeight: FontWeight.w700,
                              color:      AppColors.textPrimary,
                              fontFamily: 'monospace',
                            ),
                          ),
                          if (item.isFieldVerified) ...[
                            SizedBox(height: 3.h),
                            Text('BiliRoute Field Survey · On-site validated',
                                style: TextStyle(fontSize: 9.5.sp, color: const Color(0xFF059669))),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Action buttons
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: onFindRoute,
                      child: Container(
                        height: 46.h,
                        decoration: BoxDecoration(
                          gradient:     AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow:    [BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.route_rounded, color: Colors.white, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text('Find Best Route',
                              style: TextStyle(color: Colors.white, fontSize: 12.5.sp, fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => context.push(AppRouter.home),
                      child: Container(
                        height: 46.h,
                        decoration: BoxDecoration(
                          color:        Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border:       Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.map_rounded, color: AppColors.primary, size: 15.sp),
                          SizedBox(width: 6.w),
                          Text('Full Map',
                              style: TextStyle(color: AppColors.primary, fontSize: 12.sp, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 380.ms).fade(duration: 420.ms).slideY(begin: 0.06, end: 0);
  }
}

class _NavInfoRow extends StatelessWidget {
  const _NavInfoRow({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color    color;
  final String   label;
  final String   value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.r, height: 28.r,
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(icon, color: color, size: 13.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Route Recommendations Section
// ─────────────────────────────────────────────────────────────────────────────

class _RouteRecommendationsSection extends StatelessWidget {
  const _RouteRecommendationsSection({required this.item});
  final DestinationItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Recommended Routes', icon: Icons.alt_route_rounded, animDelay: 400),
        SizedBox(height: 14.h),
        ...item.recommendedRoutes.asMap().entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: _RouteCard(route: e.value, animIndex: e.key, item: item),
        )),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route, required this.animIndex, required this.item});
  final RecommendedRoute route;
  final int              animIndex;
  final DestinationItem  item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border:       Border.all(
          color: route.isHighlighted
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.divider,
          width: route.isHighlighted ? 1.5 : 1,
        ),
        boxShadow: [
          if (route.isHighlighted)
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            decoration: BoxDecoration(
              gradient: route.isHighlighted
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.primary.withValues(alpha: 0.08), Colors.transparent])
                  : null,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color:        route.badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                    border:       Border.all(color: route.badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(route.badge,
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: route.badgeColor)),
                ),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('₱${route.totalFare}',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  Text(route.totalDuration,
                      style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                ]),
              ],
            ),
          ),

          // Route steps
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
            child: Column(
              children: route.steps.asMap().entries.map((e) {
                final step     = e.value;
                final isLast   = e.key == route.steps.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transport icon column
                    Column(
                      children: [
                        Container(
                          width: 32.r, height: 32.r,
                          decoration: BoxDecoration(
                            color:        step.isSeaRoute
                                ? const Color(0xFF0EA5E9).withValues(alpha: 0.12)
                                : AppColors.backgroundStart,
                            borderRadius: BorderRadius.circular(10.r),
                            border:       Border.all(
                              color: step.isSeaRoute
                                  ? const Color(0xFF0EA5E9).withValues(alpha: 0.4)
                                  : AppColors.divider,
                            ),
                          ),
                          child: Icon(step.icon,
                              color:  step.isSeaRoute ? const Color(0xFF0EA5E9) : AppColors.textSecondary,
                              size:   15.sp),
                        ),
                        if (!isLast)
                          Container(
                            width: 1.5, height: 22.h,
                            color: AppColors.divider,
                          ),
                      ],
                    ),
                    SizedBox(width: 10.w),
                    // Step info
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 6.h, bottom: isLast ? 0 : 14.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${step.from} → ${step.to}',
                                      style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  SizedBox(height: 2.h),
                                  Row(children: [
                                    Text(step.mode,
                                        style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                                    if (step.isSeaRoute) ...[
                                      SizedBox(width: 6.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color:        const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text('Sea Route', style: TextStyle(fontSize: 8.5.sp, color: const Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ]),
                                ],
                              ),
                            ),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('₱${step.fare}',
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              Text(step.duration,
                                  style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          // "Use This Route" button (highlighted card only)
          if (route.isHighlighted)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
              child: GestureDetector(
                onTap: () => context.push(
                  '${AppRouter.routeSelection}?destination=${Uri.encodeComponent(item.title)}',
                  extra: TransitionPayload(
                    destinationName: item.title,
                    heroTag:         item.heroTag,
                    imageAsset:      item.imageAsset,
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient:     AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow:    [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route_rounded, color: Colors.white, size: 15.sp),
                      SizedBox(width: 8.w),
                      Text('Use This Route', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w800)),
                    ],
                  )),
                ),
              ),
            ),
        ],
      ),
    ).animate(delay: (400 + animIndex * 80).ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Safety Section
// ─────────────────────────────────────────────────────────────────────────────

class _SafetySection extends StatelessWidget {
  const _SafetySection({required this.item});
  final DestinationItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Safety & Travel Tips', icon: Icons.health_and_safety_rounded, animDelay: 450),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color:        const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20.r),
            border:       Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: item.safetyReminders.asMap().entries.map((e) => Padding(
              padding: EdgeInsets.only(bottom: e.key < item.safetyReminders.length - 1 ? 10.h : 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Container(
                    width: 22.r, height: 22.r,
                    decoration: BoxDecoration(
                      color:        AppColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(child: Text('${e.key + 1}',
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: AppColors.accent))),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(child: Text(e.value,
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF92400E), height: 1.5))),
              ]),
            )).toList(),
          ),
        ).animate(delay: 460.ms).fade(duration: 400.ms).slideY(begin: 0.06, end: 0),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky Bottom Action Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatefulWidget {
  const _BottomBar({required this.item, required this.pulseCtrl});
  final DestinationItem     item;
  final AnimationController pulseCtrl;
  @override State<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<_BottomBar> {
  bool _saved = false;
  bool _pressed = false;

  void _navigate(BuildContext ctx) {
    ctx.push(
      AppRouter.routeSelection,
      extra: TransitionPayload(
        destinationName: widget.item.title,
        heroTag:         widget.item.heroTag,
        imageAsset:      widget.item.imageAsset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, (bottom + 12).h),
      decoration: BoxDecoration(
        // Glassmorphism — frosted white with navy tint
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.92),
            Colors.white.withValues(alpha: 0.98),
          ],
        ),
        border: Border(top: BorderSide(
          color: const Color(0xFF1458D4).withValues(alpha: 0.08),
          width: 1.0,
        )),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset:     const Offset(0, -6),
          ),
          BoxShadow(
            color:      const Color(0xFF1458D4).withValues(alpha: 0.06),
            blurRadius: 12,
            offset:     const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ❤️ Save Destination button
          GestureDetector(
            onTap: () => setState(() => _saved = !_saved),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: _saved
                    ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: _saved
                      ? const Color(0xFFEF4444).withValues(alpha: 0.40)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _saved ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    size: 18.sp,
                  ).animate(target: _saved ? 1.0 : 0.0)
                      .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.25, 1.25), duration: 120.ms)
                      .then()
                      .scale(begin: const Offset(1.25, 1.25), end: const Offset(1.0, 1.0), duration: 100.ms),
                  SizedBox(height: 1.h),
                  Text('Save',
                      style: TextStyle(
                        fontSize:   9.sp,
                        color:      _saved ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // 📞 Contact Provider button
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color:        const Color(0xFFF0FDF9),
                borderRadius: BorderRadius.circular(15.r),
                border:       Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.35)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_rounded, color: const Color(0xFF0D9488), size: 18.sp),
                  SizedBox(height: 1.h),
                  Text('Contact',
                      style: TextStyle(
                        fontSize:   9.sp,
                        color:      const Color(0xFF0D9488),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // 🧭 Find Best Route — primary CTA with animated glow
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTapDown:   (_) => setState(() => _pressed = true),
              onTapUp:     (_) { setState(() => _pressed = false); _navigate(context); },
              onTapCancel: ()  => setState(() => _pressed = false),
              child: AnimatedBuilder(
                animation: widget.pulseCtrl,
                builder: (_, child) {
                  final glow = 0.22 + widget.pulseCtrl.value * 0.18;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    height: 50.h,
                    transform: Matrix4.diagonal3Values(
                      _pressed ? 0.96 : 1.0,
                      _pressed ? 0.96 : 1.0,
                      1.0,
                    ),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A2E73), Color(0xFF1458D4), Color(0xFF15C6D9)],
                        begin:  Alignment.centerLeft,
                        end:    Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color:      const Color(0xFF1458D4).withValues(alpha: glow),
                          blurRadius: 18,
                          offset:     const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.route_rounded, color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text('Find Best Route',
                        style: TextStyle(color: Colors.white, fontSize: 13.5.sp, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Shared section title widget
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon, required this.animDelay});
  final String   title;
  final IconData icon;
  final int      animDelay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.r, height: 32.r,
          decoration: BoxDecoration(
            gradient:     AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, color: Colors.white, size: 15.sp),
        ),
        SizedBox(width: 10.w),
        Text(title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ],
    ).animate(delay: animDelay.ms).fade(duration: 350.ms).slideX(begin: -0.05, end: 0);
  }
}
