import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/transitions/transition_data.dart';
import '../../../data/providers/biliran_providers.dart';
import '../../../data/providers/service_provider.dart';
import '../../../data/transport/biliran_route_options.dart';
import '../../../data/transport/route_option.dart';
import '../../../data/transport/transport_route.dart';
import '../../../widgets/ambient/breathing_card.dart';
import '../../../widgets/ambient/ocean_shimmer.dart';
import '../../../widgets/provider_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route Selection Screen
// ─────────────────────────────────────────────────────────────────────────────

/// Displays 3–5 official route options for a chosen destination.
/// User selects one before proceeding to the itinerary result screen.
class RouteSelectionScreen extends StatefulWidget {
  const RouteSelectionScreen({
    super.key,
    this.destination = 'Sambawan Island',
    this.payload,
  });

  final String             destination;
  /// Shared transition payload — carries hero tag + image through the flow.
  final TransitionPayload? payload;

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  String? _selectedId;

  late final List<RouteOption> _options;

  @override
  void initState() {
    super.initState();
    _options = BiliranRouteOptions.forDestination(widget.destination);
  }

  RouteOption? get _selected =>
      _selectedId == null
          ? null
          : _options.firstWhere((o) => o.id == _selectedId);

  void _proceed() {
    if (_selected == null) return;
    // Forward payload (with name update) to generating screen
    final payload = (widget.payload ?? TransitionPayload(
      destinationName: widget.destination,
      heroTag: 'dest_image_${widget.destination.toLowerCase().replaceAll(' ', '_')}',
    )).copyWith(destinationName: widget.destination);
    context.push(AppRouter.generating, extra: payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

          // ── Hero header ──────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context)),

          // ── Source attribution ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: _SourceBanner(),
            ),
          ),

          // ── Section label ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Route',
                    style: TextStyle(
                      fontSize:   19.sp,
                      fontWeight: FontWeight.w800,
                      color:      AppColors.textPrimary,
                    ),
                  ).animate(delay: 200.ms).fade().slideY(begin: 0.1, end: 0),
                  SizedBox(height: 4.h),
                  Text(
                    'Select the route that best fits your budget and schedule.',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color:    AppColors.textSecondary,
                      height:   1.45,
                    ),
                  ).animate(delay: 280.ms).fade(),
                ],
              ),
            ),
          ),

          // ── Route option cards ───────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                child: _RouteCard(
                  option:     _options[i],
                  isSelected: _options[i].id == _selectedId,
                  index:      i,
                  onTap:      () => setState(() => _selectedId = _options[i].id),
                ),
              ),
              childCount: _options.length,
            ),
          ),

          // ── CTA + bottom clearance ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
              child: _ProceedButton(
                enabled:      _selectedId != null,
                selectedFare: _selected?.totalFareLabel,
                onTap:        _proceed,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  // ── Image-based hero header ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final heroTag    = widget.payload?.heroTag    ?? 'dest_image_route';
    final imageAsset = widget.payload?.imageAsset ?? 'assets/images/sambawan.jpg';
    return SizedBox(
      height: 240.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image — Hero shared element ────────────────────────
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: Image.asset(
                imageAsset,
                fit:          BoxFit.cover,
                alignment:    Alignment.center,
                errorBuilder: (_, e, s) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
            ),
          ),

          // ── Dark gradient overlay ─────────────────────────────────────────
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(32)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.28),
                    Colors.black.withValues(alpha: 0.70),
                  ],
                ),
              ),
            ),
          ),

          // ── Ocean shimmer at bottom of header (sea-route indicator) ───────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: const OceanShimmer(
              height:    44,
              amplitude: 5.0,
              opacity:   0.38,
              waveColor: Color(0xFF7DD3FC),
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
                    'Route Options',
                    style: TextStyle(
                      fontSize:   28.sp,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                      shadows: [
                        Shadow(
                          color:  Colors.black.withValues(alpha: 0.30),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 500.ms).slideY(begin: 0.15, end: 0),

                  SizedBox(height: 4.h),

                  // Destination row
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size:  14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        widget.destination,
                        style: TextStyle(
                          fontSize:   14.sp,
                          color:      Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ).animate(delay: 100.ms).fade().slideY(begin: 0.15, end: 0),

                  SizedBox(height: 10.h),

                  // Stat chips
                  Row(
                    children: [
                      _HeaderChip(
                        icon:  Icons.route_rounded,
                        label: '${_options.length} routes available',
                      ),
                      SizedBox(width: 8.w),
                      _HeaderChip(
                        icon:  Icons.verified_rounded,
                        label: 'Official fares',
                      ),
                    ],
                  ).animate(delay: 200.ms).fade(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Source attribution banner ──────────────────────────────────────────────────

class _SourceBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.07),
            AppColors.info.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: AppColors.primary, size: 15.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'All fares are fixed and official — sourced from the Biliran Tourism Office.',
              style: TextStyle(
                fontSize:   11.sp,
                color:      AppColors.primary,
                height:     1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 150.ms).fade(duration: 400.ms);
  }
}

// ── Route option card ──────────────────────────────────────────────────────────

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.option,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  final RouteOption option;
  final bool        isSelected;
  final int         index;
  final VoidCallback onTap;

  Color get _labelColor {
    switch (option.label) {
      case RouteLabel.cheapest:    return AppColors.success;
      case RouteLabel.fastest:     return AppColors.info;
      case RouteLabel.recommended: return AppColors.accent;
      case RouteLabel.alternative: return AppColors.accentSoft;
      case RouteLabel.comfort:     return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BreathingCard(
      glowColor: isSelected ? _labelColor : Colors.transparent,
      duration:  const Duration(milliseconds: 2800),
      maxGlow:   isSelected ? 0.16 : 0.0,
      enabled:   isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? _labelColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:      isSelected
                  ? _labelColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: isSelected ? 18 : 12,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top row: label badge + fare ────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  // Label badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color:        _labelColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(option.label.emoji,
                            style: const TextStyle(fontSize: 12)),
                        SizedBox(width: 5.w),
                        Text(
                          option.label.text,
                          style: TextStyle(
                            fontSize:   12.sp,
                            fontWeight: FontWeight.w800,
                            color:      _labelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Selected check
                  if (isSelected)
                    Container(
                      width: 24.r, height: 24.r,
                      decoration: BoxDecoration(
                        color: _labelColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          color: Colors.white, size: 14.sp),
                    )
                  else
                    Container(
                      width: 24.r, height: 24.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider, width: 1.5),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // ── Route summary ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                option.routeSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:   13.sp,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.textPrimary,
                  height:     1.3,
                ),
              ),
            ),

            SizedBox(height: 6.h),

            // ── Description ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                option.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color:    AppColors.textSecondary,
                  height:   1.45,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Fare + duration ────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _MetricChip(
                    icon:  Icons.payments_rounded,
                    color: AppColors.accent,
                    label: option.totalFareLabel,
                    sub:   'Total Fare',
                  ),
                  SizedBox(width: 10.w),
                  _MetricChip(
                    icon:  Icons.schedule_rounded,
                    color: AppColors.info,
                    label: option.totalDurationLabel,
                    sub:   'Travel Time',
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Transport type icons ───────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _TransportSteps(segments: option.segments),
            ),

            SizedBox(height: 10.h),

            // ── Tags + sea travel warning ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  // Sea travel warning (prominent)
                  if (option.hasSeaTravel)
                    _Tag(
                      label: '🌊 Includes Sea Travel',
                      color: AppColors.info,
                      isWarning: true,
                    ),
                  // Other tags
                  ...option.tags
                      .where((t) => !t.contains('Sea'))
                      .map((t) => _Tag(label: t, color: AppColors.primary)),
                ],
              ),
            ),

            // ── Advisory note ──────────────────────────────────────────────
            if (option.note != null) ...[
              SizedBox(height: 10.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color:        AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 13.sp, color: AppColors.warning),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Text(
                        option.note!,
                        style: TextStyle(
                          fontSize:  11.sp,
                          color:     AppColors.warning,
                          height:    1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16.h),

            // ── Provider preview (only when selected) ──────────────────────
            if (isSelected)
              _ProviderPreview(segments: option.segments),
          ],
        ),
        ),
      ),
    )
        .animate(delay: (120 + index * 80).ms)
        .fade(duration: 400.ms)
        .slideY(begin: 0.07, end: 0, curve: Curves.easeOutCubic);
  }
}

// ── Provider preview (inside selected route card) ─────────────────────────────

class _ProviderPreview extends StatelessWidget {
  const _ProviderPreview({required this.segments});
  final List<TransportRoute> segments;

  @override
  Widget build(BuildContext context) {
    // Gather providers per segment
    final segmentProviders = <MapEntry<TransportRoute, List<ServiceProvider>>>[];
    for (final seg in segments) {
      final providers = BiliranProviders.forSegment(
        origin:      seg.origin,
        destination: seg.destination,
        type:        seg.type,
        limit:       2,
      );
      if (providers.isNotEmpty) {
        segmentProviders.add(MapEntry(seg, providers));
      }
    }

    if (segmentProviders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Divider(color: AppColors.divider),
        SizedBox(height: 8.h),

        // Header
        Row(
          children: [
            Icon(Icons.contacts_rounded,
                size: 14.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text(
              'Available Providers',
              style: TextStyle(
                fontSize:   12.5.sp,
                fontWeight: FontWeight.w700,
                color:      AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        ...segmentProviders.map((entry) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: SegmentProviderSection(
                segmentLabel: entry.key.routeLabel,
                providers:    entry.value,
                isWater:      entry.key.type.isWater,
                compact:      true,
              ),
            )),

        // Advisory note
        Container(
          margin:  EdgeInsets.only(top: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color:        AppColors.info.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 12.sp, color: AppColors.info),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Contact providers in advance to confirm availability.',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color:    AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
    ).animate().fade(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

// ── Transport steps ────────────────────────────────────────────────────────────

class _TransportSteps extends StatelessWidget {
  const _TransportSteps({required this.segments});
  final List<TransportRoute> segments;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (var i = 0; i < segments.length; i++) {
      final s = segments[i];
      children.add(_StepIcon(type: s.type));
      if (i < segments.length - 1) {
        children.add(
          Expanded(
            child: Container(
              height: 1.5,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              color: AppColors.divider,
            ),
          ),
        );
      }
    }

    return Row(
      children: [
        ...children,
        const Spacer(),
        // Fare breakdown tooltip
        Text(
          segments.map((s) => s.fareLabel).join(' + '),
          style: TextStyle(
            fontSize:  10.5.sp,
            color:     AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.type});
  final TransportType type;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: type.label,
      child: Container(
        width: 30.r, height: 30.r,
        decoration: BoxDecoration(
          color:  type.color.withValues(alpha: 0.12),
          shape:  BoxShape.circle,
        ),
        child: Icon(type.icon, color: type.color, size: 15.sp),
      ),
    );
  }
}

// ── Metric chip ────────────────────────────────────────────────────────────────

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
  });
  final IconData icon;
  final Color    color;
  final String   label;
  final String   sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border:       Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize:   14.sp,
                  fontWeight: FontWeight.w800,
                  color:      color,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                    fontSize: 9.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tag chip ───────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, this.isWarning = false});
  final String label;
  final Color  color;
  final bool   isWarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: isWarning ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(99),
        border:       Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   10.sp,
          fontWeight: isWarning ? FontWeight.w700 : FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }
}

// ── Header chip ────────────────────────────────────────────────────────────────

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color:      Colors.white,
              fontSize:   11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Proceed CTA button ─────────────────────────────────────────────────────────

class _ProceedButton extends StatelessWidget {
  const _ProceedButton({
    required this.enabled,
    required this.onTap,
    this.selectedFare,
  });
  final bool        enabled;
  final String?     selectedFare;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity:  enabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            gradient: enabled
                ? AppColors.primaryGradient
                : const LinearGradient(
                    colors: [Color(0xFFB0BEC5), Color(0xFF90A4AE)]),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: enabled
                ? [BoxShadow(
                    color:      AppColors.primary.withValues(alpha: 0.32),
                    blurRadius: 20,
                    offset:     const Offset(0, 8))]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.route_rounded,
                  color: Colors.white, size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                enabled
                    ? 'Confirm Route  ·  $selectedFare'
                    : 'Select a Route to Continue',
                style: TextStyle(
                  color:      Colors.white,
                  fontSize:   15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: 400.ms)
        .fade(duration: 400.ms)
        .slideY(begin: 0.06, end: 0);
  }
}
