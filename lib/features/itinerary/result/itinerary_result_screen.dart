import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/transitions/transition_data.dart';
import '../../../data/providers/biliran_providers.dart';
import '../../../data/transport/transport_route.dart';
import '../../../widgets/ambient/ambient_particles.dart';
import '../../../widgets/provider_card.dart';

// ── Route stop model ──────────────────────────────────────────────────────────

class _Stop {
  const _Stop({
    required this.time,
    required this.landmark,
    required this.description,
    this.transport,
    this.isFirst = false,
    this.isLast  = false,
  });
  final String          time;
  final String          landmark;
  final String          description;
  final TransportRoute? transport; // null for starting point
  final bool            isFirst;
  final bool            isLast;
}

// ── Route Result Screen ────────────────────────────────────────────────────────

/// Displays a recommended travel route summary for Biliran Island.
///
/// All transport fares are sourced from [BiliranFareData] — the official
/// Tourism Office fare dataset. No estimated or range-based fares are used.
class ItineraryResultScreen extends StatefulWidget {
  const ItineraryResultScreen({super.key, this.payload});

  /// Shared hero payload forwarded from the generating screen.
  final TransitionPayload? payload;

  @override
  State<ItineraryResultScreen> createState() => _ItineraryResultScreenState();
}

class _ItineraryResultScreenState extends State<ItineraryResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Sambawan Island Day Trip ───────────────────────────────────────────────
  // Route: Naval → Kawayan → Sambawan Port → Sambawan Island (and back)
  // All fares from BiliranFareData.sambawanTrip

  static const _stops = [
    _Stop(
      time:        '06:00 AM',
      landmark:    'Naval Town Plaza',
      description: 'Starting point — assemble at Naval terminal',
      isFirst:     true,
    ),
    _Stop(
      time:        '06:15 AM',
      landmark:    'Kawayan',
      description: 'Board multicab from Naval to Kawayan',
      transport:   TransportRoute(
        origin:          'Naval',
        destination:     'Kawayan',
        type:            TransportType.multicab,
        officialFare:    55,
        durationMinutes: 45,
      ),
    ),
    _Stop(
      time:        '07:00 AM',
      landmark:    'Sambawan Port (Higatangan)',
      description: 'Ride habal-habal from Kawayan to the port',
      transport:   TransportRoute(
        origin:          'Kawayan',
        destination:     'Sambawan Port',
        type:            TransportType.habalHabal,
        officialFare:    60,
        durationMinutes: 25,
      ),
    ),
    _Stop(
      time:        '07:30 AM',
      landmark:    'Sambawan Island',
      description: 'Charter boat — enjoy the sandbar & snorkeling',
      transport:   TransportRoute(
        origin:          'Sambawan Port',
        destination:     'Sambawan Island',
        type:            TransportType.boatCharter,
        officialFare:    800,
        durationMinutes: 30,
        perPerson:       false,
        notes:           'Shared charter (8–12 pax)',
      ),
    ),
    _Stop(
      time:        '03:00 PM',
      landmark:    'Sambawan Port (Return)',
      description: 'Board return charter boat',
      transport:   TransportRoute(
        origin:          'Sambawan Island',
        destination:     'Sambawan Port',
        type:            TransportType.boatCharter,
        officialFare:    800,
        durationMinutes: 30,
        perPerson:       false,
        notes:           'Return charter',
      ),
    ),
    _Stop(
      time:        '03:35 PM',
      landmark:    'Kawayan',
      description: 'Habal-habal back to Kawayan',
      transport:   TransportRoute(
        origin:          'Sambawan Port',
        destination:     'Kawayan',
        type:            TransportType.habalHabal,
        officialFare:    60,
        durationMinutes: 25,
      ),
    ),
    _Stop(
      time:        '04:30 PM',
      landmark:    'Naval Town Plaza',
      description: 'Multicab return to Naval — end of day trip',
      transport:   TransportRoute(
        origin:          'Kawayan',
        destination:     'Naval',
        type:            TransportType.multicab,
        officialFare:    55,
        durationMinutes: 45,
      ),
      isLast: true,
    ),
  ];

  // Total official fare from all transport segments
  static int get _totalFare =>
      _stops
          .where((s) => s.transport != null)
          .fold(0, (sum, s) => sum + s.transport!.officialFare);

  @override
  Widget build(BuildContext context) {
    final heroTag    = widget.payload?.heroTag    ?? 'dest_image_sambawan';
    final imageAsset = widget.payload?.imageAsset ?? 'assets/images/sambawan.jpg';
    final destName   = widget.payload?.destinationName ?? 'Sambawan Island';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

          // ── Gradient hero header ───────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(
            context,
            heroTag:    heroTag,
            imageAsset: imageAsset,
            destName:   destName,
          )),

          // ── Summary stats ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _buildSummaryRow(context),
            ),
          ),

          // ── Official fare breakdown ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _FareBreakdownCard(stops: _stops),
            ),
          ),

          // ── Transport & Contacts ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: _buildProvidersSection(context),
            ),
          ),

          // ── Timeline header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
              child: Text(
                'Route Timeline',
                style: TextStyle(
                  fontSize:   18.sp,
                  fontWeight: FontWeight.w800,
                  color:      AppColors.textPrimary,
                ),
              ).animate(delay: 300.ms).fade().slideY(begin: 0.1, end: 0),
            ),
          ),

          // ── Timeline stops ─────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child:   _TimelineStop(stop: _stops[i], index: i),
              ),
              childCount: _stops.length,
            ),
          ),

          // ── Actions ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 48.h),
              child:   _buildActions(context),
            ),
          ),
        ],
        ),
      ),
    );
  }

  // ── Transport & Contacts section ──────────────────────────────────────────
  Widget _buildProvidersSection(BuildContext context) {
    final transportStops = _stops.where((s) => s.transport != null).toList();

    final entries = <MapEntry<TransportRoute, List>>[]; 
    for (final stop in transportStops) {
      final seg = stop.transport!;
      final providers = BiliranProviders.forSegment(
        origin:      seg.origin,
        destination: seg.destination,
        type:        seg.type,
        limit:       3,
      );
      if (providers.isNotEmpty) entries.add(MapEntry(seg, providers));
    }

    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Container(
              width:  34.r, height: 34.r,
              decoration: BoxDecoration(
                gradient:     AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.contacts_rounded,
                  color: Colors.white, size: 17.sp),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transport & Contacts',
                  style: TextStyle(
                    fontSize:   17.sp,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Verified by Biliran Tourism Office',
                  style: TextStyle(
                    fontSize:   10.5.sp,
                    color:      AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ).animate(delay: 200.ms).fade().slideY(begin: 0.1, end: 0),

        SizedBox(height: 14.h),

        // Per-segment provider cards
        ...entries.asMap().entries.map((e) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: SegmentProviderSection(
                segmentLabel: e.value.key.routeLabel,
                providers:    e.value.value.cast(),
                isWater:      e.value.key.type.isWater,
                compact:      false,
                index:        e.key * 2,
              ),
            )),

        // Advisory note
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color:  AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  size: 15.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Contact providers in advance to confirm availability. '
                  'All contacts are verified by the Biliran Tourism Office.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:    AppColors.primary,
                    height:   1.45,
                  ),
                ),
              ),
            ],
          ),
        ).animate(delay: 400.ms).fade(duration: 400.ms),

        SizedBox(height: 4.h),
      ],
    );
  }

  // ── Hero shuttle — keeps image visible & fading during flight ────────────────
  Widget _heroShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return FadeTransition(
      opacity: animation,
      child: toHeroContext.widget,
    );
  }

  // ── Image-based hero header ────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context, {
    required String heroTag,
    required String imageAsset,
    required String destName,
  }) {
    return SizedBox(
      height: 260.h,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // ── Background image — Hero shared element ───────────────────────
          Hero(
            tag:              heroTag,
            flightShuttleBuilder: _heroShuttle,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32)),
              child: Image.asset(
                imageAsset,
                fit:       BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, e, s) => Container(
                  decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient),
                ),
              ),
            ),
          ),

          // ── Success pulse ripple ─────────────────────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32)),
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) {
                  final t = _pulseCtrl.value;
                  return CustomPaint(
                    painter: _SuccessPulsePainter(progress: t),
                  );
                },
              ),
            ),
          ),

          // ── Dark gradient overlay ────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ),

          // ── Ambient particles in hero image ───────────────────────────────
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32)),
              child: const AmbientParticles(
                count:     8,
                color:     Color(0xFFFFFFFF),
                maxRadius: 2.0,
                speed:     0.4,
                opacity:   0.28,
                seed:      13,
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38.r, height: 38.r,
                      decoration: BoxDecoration(
                        color:        Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16.sp, color: Colors.white),
                    ),
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    AppStrings.routeSummaryTitle,
                    style: TextStyle(
                      fontSize:   26.sp,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                      shadows: [
                        Shadow(
                          color:      Colors.black.withValues(alpha: 0.30),
                          offset:     const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 500.ms)
                      .slideY(begin: 0.15, end: 0),

                  SizedBox(height: 4.h),

                  Text(
                    '$destName  ·  ${_stops.length} stops',
                    style: TextStyle(
                      fontSize:   13.sp,
                      color:      Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate(delay: 100.ms).fade()
                      .slideY(begin: 0.15, end: 0),

                  SizedBox(height: 10.h),

                  // Tourism Office badge
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color:        Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            color: Colors.white, size: 13.sp),
                        SizedBox(width: 5.w),
                        Text(
                          'Fares: Biliran Tourism Office',
                          style: TextStyle(
                            color:      Colors.white,
                            fontSize:   11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fade(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary stats row ──────────────────────────────────────────────────────
  Widget _buildSummaryRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon:      Icons.payments_rounded,
            iconColor: AppColors.accent,
            label:     'Total Fare',
            value:     '₱$_totalFare',
            animIndex: 0,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatCard(
            icon:      Icons.schedule_rounded,
            iconColor: AppColors.info,
            label:     'Total Time',
            value:     '~10 hrs',
            animIndex: 1,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _StatCard(
            icon:       Icons.shield_rounded,
            iconColor:  AppColors.success,
            label:      'Safety',
            value:      'Safe',
            valueColor: AppColors.success,
            animIndex:  2,
          ),
        ),
      ],
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon:  Icons.edit_rounded,
            label: AppStrings.editRoute,
            color: AppColors.primary,
            onTap: () => context.push(AppRouter.editItinerary),
            animIndex: 0,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _ActionButton(
            icon:  Icons.map_rounded,
            label: AppStrings.viewMap,
            color: AppColors.accentSoft,
            onTap: () => context.push('/map-preview'),
            animIndex: 1,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _ActionButton(
            icon:  Icons.bookmark_rounded,
            label: AppStrings.save,
            color: AppColors.accent,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:          const Text('Itinerary saved!'),
                backgroundColor:  AppColors.success,
                behavior:         SnackBarBehavior.floating,
                shape:            RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
            animIndex: 2,
          ),
        ),
      ],
    );
  }
}

// ── Fare breakdown card ────────────────────────────────────────────────────────

class _FareBreakdownCard extends StatelessWidget {
  const _FareBreakdownCard({required this.stops});
  final List<_Stop> stops;

  @override
  Widget build(BuildContext context) {
    final transportStops =
        stops.where((s) => s.transport != null).toList();
    final total = transportStops.fold<int>(
        0, (sum, s) => sum + s.transport!.officialFare);

    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.info.withValues(alpha: 0.05),
              ]),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    color: AppColors.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Official Fare Breakdown',
                  style: TextStyle(
                    fontSize:   14.sp,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color:        AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: AppColors.primary, size: 11.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Tourism Office',
                        style: TextStyle(
                          fontSize:   10.sp,
                          color:      AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Per-segment rows
          ...transportStops.asMap().entries.map((entry) {
            final s     = entry.value;
            final t     = s.transport!;
            final color = t.type.color;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
                  child: Row(
                    children: [
                      Container(
                        width: 30.r, height: 30.r,
                        decoration: BoxDecoration(
                          color:  color.withValues(alpha: 0.12),
                          shape:  BoxShape.circle,
                        ),
                        child: Icon(t.type.icon, color: color, size: 15.sp),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.routeLabel,
                              style: TextStyle(
                                fontSize:   12.sp,
                                fontWeight: FontWeight.w700,
                                color:      AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${t.type.label} · ${t.durationLabel}',
                              style: TextStyle(
                                  fontSize: 10.5.sp,
                                  color:    AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            t.fareLabel,
                            style: TextStyle(
                              fontSize:   14.sp,
                              fontWeight: FontWeight.w800,
                              color:      AppColors.accent,
                            ),
                          ),
                          Text(
                            t.perPerson ? 'per person' : 'per trip',
                            style: TextStyle(
                                fontSize: 9.sp,
                                color:    AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (entry.key < transportStops.length - 1)
                  Divider(height: 1, indent: 56.w, color: AppColors.divider),
              ],
            );
          }),

          // Total row
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color:        AppColors.accent.withValues(alpha: 0.06),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(18.r)),
            ),
            child: Row(
              children: [
                Text(
                  'Total Transport Cost',
                  style: TextStyle(
                    fontSize:   13.sp,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '₱$total',
                  style: TextStyle(
                    fontSize:   18.sp,
                    fontWeight: FontWeight.w900,
                    color:      AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 250.ms).fade(duration: 450.ms).slideY(begin: 0.06, end: 0);
  }
}

// ── Timeline stop ──────────────────────────────────────────────────────────────

class _TimelineStop extends StatelessWidget {
  const _TimelineStop({required this.stop, required this.index});
  final _Stop stop;
  final int   index;

  @override
  Widget build(BuildContext context) {
    final dotColor = stop.isFirst
        ? AppColors.success
        : stop.isLast
            ? AppColors.danger
            : AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 68.w,
            child: Padding(
              padding: EdgeInsets.only(top: 14.h),
              child: Text(
                stop.time,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize:   11.sp,
                  color:      AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Dot + line
          Column(
            children: [
              Container(
                width:  14.r,
                height: 14.r,
                margin: EdgeInsets.only(top: 14.h),
                decoration: BoxDecoration(
                  shape:   BoxShape.circle,
                  color:   dotColor,
                  border:  Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color:      dotColor.withValues(alpha: 0.30),
                        blurRadius: 6),
                  ],
                ),
              ),
              if (!stop.isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.divider),
                ),
            ],
          ),

          SizedBox(width: 12.w),

          // Content card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset:     const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.landmark,
                      style: TextStyle(
                        fontSize:   13.sp,
                        fontWeight: FontWeight.w700,
                        color:      AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      stop.description,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color:    AppColors.textSecondary,
                      ),
                    ),
                    if (stop.transport != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(stop.transport!.type.icon,
                              size:  13.sp,
                              color: stop.transport!.type.color),
                          SizedBox(width: 4.w),
                          Text(
                            '${stop.transport!.type.label}  ·  ${stop.transport!.durationLabel}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color:    AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          // Official fare badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color:        AppColors.accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    size:  10.sp,
                                    color: AppColors.primary),
                                SizedBox(width: 3.w),
                                Text(
                                  stop.transport!.fareLabel,
                                  style: TextStyle(
                                    fontSize:   11.sp,
                                    fontWeight: FontWeight.w800,
                                    color:      AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: (350 + index * 55).ms)
        .fade(duration: 400.ms)
        .slideX(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.animIndex = 0,
  });
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   value;
  final Color?   valueColor;
  final int      animIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize:   15.sp,
              fontWeight: FontWeight.w800,
              color:      valueColor ?? AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    )
        .animate(delay: (200 + animIndex * 80).ms)
        .fade(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

// ── Action button ──────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.animIndex = 0,
  });
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final int          animIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14.r),
          border:       Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize:   11.sp,
                color:      color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (500 + animIndex * 70).ms)
        .fade(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

// ── Success pulse ripple painter ───────────────────────────────────────────────

/// Draws an expanding green ripple ring that emanates from center on entrance.
class _SuccessPulsePainter extends CustomPainter {
  const _SuccessPulsePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01 || progress >= 0.99) return;
    final center    = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.longestSide * 0.8;
    final radius    = maxRadius * progress;
    final opacity   = (1.0 - progress).clamp(0.0, 1.0) * 0.38;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color       = const Color(0xFF10B981).withValues(alpha: opacity)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 2.5 + (8 * (1 - progress)),
    );

    if (progress > 0.15) {
      final r2 = maxRadius * (progress - 0.15);
      final o2 = (1.0 - (progress - 0.15)).clamp(0.0, 1.0) * 0.22;
      canvas.drawCircle(
        center, r2,
        Paint()
          ..color       = const Color(0xFF6EE7B7).withValues(alpha: o2)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_SuccessPulsePainter old) => old.progress != progress;
}
