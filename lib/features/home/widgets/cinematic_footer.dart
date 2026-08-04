import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/ambient/ambient_particles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cinematic BiliRoute Footer
// ─────────────────────────────────────────────────────────────────────────────

class CinematicFooter extends StatefulWidget {
  const CinematicFooter({
    super.key,
    this.onExploreMap,
    this.onPlanTrip,
  });

  final VoidCallback? onExploreMap;
  final VoidCallback? onPlanTrip;

  @override
  State<CinematicFooter> createState() => _CinematicFooterState();
}

class _CinematicFooterState extends State<CinematicFooter>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _countCtrl;
  late final Animation<double>   _countAnim;

  static const _stats = [
    (icon: '🏝', value: 120, suffix: '+',  label: 'Destinations'),
    (icon: '🚐', value: 48,  suffix: '',   label: 'Verified Providers'),
    (icon: '🧭', value: 350, suffix: '+',  label: 'Smart Routes'),
    (icon: '🌤', value: 24,  suffix: '/7', label: 'Live Monitoring'),
  ];

  static const _systemStatus = [
    (label: 'Route Engine',      sublabel: 'Online',   color: Color(0xFF10B981)),
    (label: 'Weather Monitoring', sublabel: 'Active',   color: Color(0xFF06B6D4)),
    (label: 'Tourism Office',    sublabel: 'Verified', color: Color(0xFF6366F1)),
  ];

  static const _links = [
    (label: 'Explore Map',     icon: Icons.map_rounded),
    (label: 'Find Routes',     icon: Icons.route_rounded),
    (label: 'Fare Guide',      icon: Icons.payments_rounded),
    (label: 'Travel Advisory', icon: Icons.shield_rounded),
  ];

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _countCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 2000),
    );
    _countAnim = CurvedAnimation(
      parent: _countCtrl,
      curve:  Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _countCtrl.forward();
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft:  Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      // Stack: background fills, content stacks on top
      child: Stack(
        children: [
          // ── Background (Positioned.fill so it doesn't drive Stack size) ──
          Positioned.fill(
            child: _OceanBackground(),
          ),

          // ── Ambient particles ─────────────────────────────────────────────
          const Positioned.fill(
            child: AmbientParticles(
              count:     22,
              color:     Color(0xFF7DD3FC),
              maxRadius: 2.8,
              speed:     0.35,
              opacity:   0.45,
              seed:      42,
            ),
          ),

          // ── Content (drives the Stack's height) ───────────────────────────
          _FooterContent(
            stats:        _stats,
            systemStatus: _systemStatus,
            links:        _links,
            pulseCtrl:    _pulseCtrl,
            countAnim:    _countAnim,
            waveCtrl:     _waveCtrl,
            onExploreMap: widget.onExploreMap,
            onPlanTrip:   widget.onPlanTrip,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ocean gradient background
// ─────────────────────────────────────────────────────────────────────────────

class _OceanBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          stops:  [0.0, 0.35, 0.65, 1.0],
          colors: [
            Color(0xFF0F2554),
            Color(0xFF0E3A6E),
            Color(0xFF0A4F72),
            Color(0xFF053D5E),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60, left: -40,
            child: Container(
              width:  260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0EA5E9).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40, right: -40,
            child: Container(
              width:  220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withValues(alpha: 0.14),
                    Colors.transparent,
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
// Wave shimmer painter
// ─────────────────────────────────────────────────────────────────────────────

class _WaveShimmer extends StatelessWidget {
  const _WaveShimmer({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => CustomPaint(
        painter: _WavePainter(controller.value),
        size: Size(double.infinity, 55),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    for (var layer = 0; layer < 3; layer++) {
      final offset    = t * 2 * math.pi + layer * math.pi / 1.5;
      final alpha     = 0.08 - layer * 0.02;
      final amplitude = 8.0 - layer * 2.0;
      final path      = Path()..moveTo(0, h * 0.5);

      for (var x = 0.0; x <= w; x++) {
        final y = h * 0.5 +
            math.sin((x / w * 2 * math.pi) + offset) * amplitude +
            math.sin((x / w * 4 * math.pi) + offset * 1.4) * (amplitude * 0.4);
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF06B6D4).withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main content column  (drives the Stack's intrinsic height)
// ─────────────────────────────────────────────────────────────────────────────

class _FooterContent extends StatelessWidget {
  const _FooterContent({
    required this.stats,
    required this.systemStatus,
    required this.links,
    required this.pulseCtrl,
    required this.countAnim,
    required this.waveCtrl,
    required this.onExploreMap,
    required this.onPlanTrip,
  });

  final List<({String icon, int value, String suffix, String label})> stats;
  final List<({String label, String sublabel, Color color})>          systemStatus;
  final List<({String label, IconData icon})>                         links;
  final AnimationController pulseCtrl;
  final AnimationController waveCtrl;
  final Animation<double>   countAnim;
  final VoidCallback?       onExploreMap;
  final VoidCallback?       onPlanTrip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 36.h, 20.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Wordmark ──────────────────────────────────────────────────
          _Wordmark()
              .animate().fade(duration: 500.ms),

          SizedBox(height: 24.h),

          // ── Headline ──────────────────────────────────────────────────
          Text(
            'Discover Biliran\nSmarter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:      30.sp,
              fontWeight:    FontWeight.w900,
              color:         Colors.white,
              height:        1.15,
              letterSpacing: -0.5,
            ),
          )
              .animate(delay: 100.ms)
              .fade(duration: 600.ms)
              .slideY(begin: 0.15, end: 0),

          SizedBox(height: 10.h),

          Text(
            'BiliRoute helps tourists discover verified\ntransportation routes, local providers, and safer\ntravel experiences across Biliran Province.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              color:    Colors.white.withValues(alpha: 0.65),
              height:   1.6,
            ),
          )
              .animate(delay: 180.ms)
              .fade(duration: 600.ms),

          SizedBox(height: 28.h),

          // ── Stats 2×2 grid (using Row+Column instead of GridView) ─────
          _StatsGrid(stats: stats, countAnim: countAnim)
              .animate(delay: 260.ms)
              .fade(duration: 600.ms)
              .slideY(begin: 0.10, end: 0),

          SizedBox(height: 26.h),

          // ── Divider ───────────────────────────────────────────────────
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(delay: 330.ms).fade(duration: 500.ms),

          SizedBox(height: 24.h),

          // ── System Status ─────────────────────────────────────────────
          _SystemStatus(items: systemStatus, pulseCtrl: pulseCtrl)
              .animate(delay: 380.ms)
              .fade(duration: 600.ms),

          SizedBox(height: 24.h),

          // ── Trust statement ───────────────────────────────────────────
          _TrustStatement()
              .animate(delay: 450.ms)
              .fade(duration: 600.ms),

          SizedBox(height: 28.h),

          // ── Quick links ───────────────────────────────────────────────
          _QuickLinks(
            items:        links,
            onExploreMap: onExploreMap,
            onPlanTrip:   onPlanTrip,
          ).animate(delay: 520.ms).fade(duration: 500.ms),

          SizedBox(height: 28.h),

          // ── Wave strip ────────────────────────────────────────────────
          _WaveShimmer(controller: waveCtrl)
              .animate(delay: 560.ms)
              .fade(duration: 500.ms),

          SizedBox(height: 18.h),

          // ── Copyright ─────────────────────────────────────────────────
          _Copyright()
              .animate(delay: 600.ms)
              .fade(duration: 500.ms),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wordmark
// ─────────────────────────────────────────────────────────────────────────────

class _Wordmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width:  42.r,
          height: 42.r,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color:      const Color(0xFF06B6D4).withValues(alpha: 0.45),
                blurRadius: 18,
                offset:     const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.explore_rounded, color: Colors.white, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BiliRoute',
              style: TextStyle(
                color:         Colors.white,
                fontSize:      22.sp,
                fontWeight:    FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Smart Mobility Platform',
              style: TextStyle(
                color:         const Color(0xFF7DD3FC),
                fontSize:      9.5.sp,
                fontWeight:    FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats grid — Row+Column instead of GridView to avoid unbounded constraints
// ─────────────────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.countAnim});
  final List<({String icon, int value, String suffix, String label})> stats;
  final Animation<double> countAnim;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(stat: stats[0], countAnim: countAnim, delay: 0.ms)),
            SizedBox(width: 12.w),
            Expanded(child: _StatCard(stat: stats[1], countAnim: countAnim, delay: 60.ms)),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _StatCard(stat: stats[2], countAnim: countAnim, delay: 120.ms)),
            SizedBox(width: 12.w),
            Expanded(child: _StatCard(stat: stats[3], countAnim: countAnim, delay: 180.ms)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.stat,
    required this.countAnim,
    required this.delay,
  });
  final ({String icon, int value, String suffix, String label}) stat;
  final Animation<double> countAnim;
  final Duration          delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: countAnim,
      builder: (context, child) {
        final current = (countAnim.value * stat.value).round();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Text(stat.icon, style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$current${stat.suffix}',
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   15.sp,
                        fontWeight: FontWeight.w900,
                        height:     1.1,
                      ),
                    ),
                    Text(
                      stat.label,
                      style: TextStyle(
                        color:      Colors.white.withValues(alpha: 0.58),
                        fontSize:   8.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).animate(delay: delay).fade(duration: 400.ms).slideY(begin: 0.10, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// System status
// ─────────────────────────────────────────────────────────────────────────────

class _SystemStatus extends StatelessWidget {
  const _SystemStatus({required this.items, required this.pulseCtrl});
  final List<({String label, String sublabel, Color color})> items;
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:        Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SYSTEM STATUS',
            style: TextStyle(
              color:         Colors.white.withValues(alpha: 0.42),
              fontSize:      9.sp,
              fontWeight:    FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          ...items.asMap().entries.map((e) => Padding(
            padding: EdgeInsets.only(
                bottom: e.key < items.length - 1 ? 10.h : 0),
            child: _StatusRow(item: e.value, pulseCtrl: pulseCtrl),
          )),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.item, required this.pulseCtrl});
  final ({String label, String sublabel, Color color}) item;
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: pulseCtrl,
          builder: (context, child) {
            final alpha = 0.55 + pulseCtrl.value * 0.45;
            final blur  = 3.0  + pulseCtrl.value * 5.0;
            return Container(
              width:  9.r,
              height: 9.r,
              decoration: BoxDecoration(
                color:  item.color.withValues(alpha: alpha),
                shape:  BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:      item.color.withValues(alpha: 0.60),
                    blurRadius: blur,
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            item.label,
            style: TextStyle(
              color:      Colors.white.withValues(alpha: 0.80),
              fontSize:   11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color:        item.color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(99),
            border:       Border.all(
              color: item.color.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Text(
            item.sublabel,
            style: TextStyle(
              color:      item.color,
              fontSize:   8.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trust statement
// ─────────────────────────────────────────────────────────────────────────────

class _TrustStatement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Built to support sustainable and connected\ntourism experiences for Biliran travelers.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize:  12.sp,
            color:     Colors.white.withValues(alpha: 0.62),
            height:    1.6,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF06B6D4).withValues(alpha: 0.15),
                const Color(0xFF0EA5E9).withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded,
                  color: const Color(0xFF06B6D4), size: 13.sp),
              SizedBox(width: 7.w),
              Flexible(
                child: Text(
                  'Prototype integrated with Biliran Tourism Office concepts',
                  style: TextStyle(
                    color:      const Color(0xFF7DD3FC),
                    fontSize:   9.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick links
// ─────────────────────────────────────────────────────────────────────────────

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({
    required this.items,
    required this.onExploreMap,
    required this.onPlanTrip,
  });
  final List<({String label, IconData icon})> items;
  final VoidCallback? onExploreMap;
  final VoidCallback? onPlanTrip;

  VoidCallback? _callbackFor(String label) {
    if (label == 'Explore Map') return onExploreMap;
    if (label == 'Plan Trip')   return onPlanTrip;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'QUICK ACCESS',
          style: TextStyle(
            color:         Colors.white.withValues(alpha: 0.38),
            fontSize:      9.sp,
            fontWeight:    FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 14.h),
        Wrap(
          alignment:  WrapAlignment.center,
          spacing:    10.w,
          runSpacing: 10.h,
          children: items.asMap().entries.map((e) {
            final item = e.value;
            return _QuickLinkBtn(
              label: item.label,
              icon:  item.icon,
              onTap: _callbackFor(item.label),
              delay: (e.key * 55).ms,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickLinkBtn extends StatefulWidget {
  const _QuickLinkBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.delay,
  });
  final String        label;
  final IconData      icon;
  final VoidCallback? onTap;
  final Duration      delay;

  @override
  State<_QuickLinkBtn> createState() => _QuickLinkBtnState();
}

class _QuickLinkBtnState extends State<_QuickLinkBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: _pressed
                ? Colors.white.withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.13),
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color:      const Color(0xFF06B6D4).withValues(alpha: 0.30),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size:  11.sp,
              color: _pressed
                  ? const Color(0xFF7DD3FC)
                  : Colors.white.withValues(alpha: 0.68),
            ),
            SizedBox(width: 6.w),
            Text(
              widget.label,
              style: TextStyle(
                color: _pressed
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.68),
                fontSize:   10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: widget.delay)
        .fade(duration: 350.ms)
        .slideY(begin: 0.08, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Copyright
// ─────────────────────────────────────────────────────────────────────────────

class _Copyright extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.10),
                Colors.transparent,
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_rounded,
                size: 11.sp, color: Colors.white.withValues(alpha: 0.28)),
            SizedBox(width: 5.w),
            Text(
              'BiliRoute v1.0.0',
              style: TextStyle(
                color:      Colors.white.withValues(alpha: 0.38),
                fontSize:   9.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '© 2026 BiliRoute — Smart Tourism Mobility Platform',
          style: TextStyle(
            color:    Colors.white.withValues(alpha: 0.26),
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}
