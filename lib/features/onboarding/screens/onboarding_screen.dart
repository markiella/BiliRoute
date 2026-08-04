import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/ambient/ambient_particles.dart';

// ── Page model ─────────────────────────────────────────────────────────────────

class _OnboardingPage {
  const _OnboardingPage({
    required this.lottie,
    required this.images,   // 3 Biliran destination photos for stacked cards
    required this.badge,    // location label on the front card
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.accentColor,
    this.showLottie = false,
  });
  final String       lottie;
  final List<String> images;
  final String       badge;
  final String       title;
  final String       subtitle;
  final List<String> bullets;
  final Color        accentColor;
  final bool         showLottie;
}

// ── Onboarding content ────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      lottie:      AppAssets.welcomeLottie,
      showLottie:  true,
      images:   [
        'assets/images/sambawan.jpg',
        'assets/images/agta.JPG',
        'assets/images/dalutan.jpg',
      ],
      badge:      'Sambawan Island, Biliran',
      title:      'Travel and Explore\nBiliran Island',
      subtitle:   'Discover pristine beaches, hidden waterfalls and island getaways in one app.',
      bullets:    [],
      accentColor: AppColors.primary,
    ),
    _OnboardingPage(
      lottie:   AppAssets.thinkingLottie,
      images:   [
        'assets/images/ulan-ulan.jpg',
        'assets/images/sambawan.jpg',
        'assets/images/agta.JPG',
      ],
      badge:      'Ulan-Ulan Falls, Almeria',
      title:      'Planning trips is\nchallenging',
      subtitle:   'No reliable info on routes, fares, or safety — BiliRoute solves that.',
      bullets: [
        '🗺️  Hard to find reliable destinations',
        '🚌  No clear route or transport info',
        '💸  Uncertain fares and schedules',
      ],
      accentColor: AppColors.warning,
    ),
    _OnboardingPage(
      lottie:   AppAssets.planningLottie,
      images:   [
        'assets/images/dalutan.jpg',
        'assets/images/ulan-ulan.jpg',
        'assets/images/sambawan.jpg',
      ],
      badge:      'Dalutan Island, Almeria',
      title:      'Navigate smarter with\nBiliRoute',
      subtitle:   'Verified route recommendations, optimised transport guidance and safety-aware travel planning.',
      bullets: [
        '🧭  Smart route recommendations',
        '📍  Verified transport & fare guide',
        '🛡️  Safety-aware travel planning',
      ],
      accentColor: AppColors.success,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve:    Curves.easeOutCubic,
      );
    } else {
      context.go(AppRouter.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: Stack(
        children: [
          // ── Ambient particle background ────────────────────────────────────
          Positioned.fill(
            child: AmbientParticles(
              count:     10,
              color:     const Color(0xFF7DD3FC),
              maxRadius: 3.0,
              speed:     0.45,
              opacity:   0.40,
              seed:      _currentPage * 37,
            ),
          ),

          PageView.builder(
            controller:    _controller,
            itemCount:     _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder:   (context, i) => _PageContent(page: _pages[i]),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomBar(
              currentPage: _currentPage,
              totalPages:  _pages.length,
              isLast:      _currentPage == _pages.length - 1,
              accent:      _pages[_currentPage].accentColor,
              onNext:      _next,
              onSkip:      () => context.go(AppRouter.login),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single page ────────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          // ── Main column content ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 160.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StackedCards(
                    images:      page.images,
                    badge:       page.badge,
                    accentColor: page.accentColor,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  page.title,
                  style: TextStyle(
                    fontSize:   26.sp,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.textPrimary,
                    height:     1.22,
                  ),
                ).animate(delay: 200.ms).fade(duration: 500.ms).slideY(begin: 0.15, end: 0),
                SizedBox(height: 8.h),
                Text(
                  page.subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color:    AppColors.textSecondary,
                    height:   1.55,
                  ),
                ).animate(delay: 300.ms).fade(duration: 500.ms),
                if (page.bullets.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  ...page.bullets.asMap().entries.map((e) => _Bullet(
                        text:        e.value,
                        delay:       Duration(milliseconds: 370 + e.key * 80),
                        accentColor: page.accentColor,
                      )),
                ],
              ],
            ),
          ),

          // ── Lottie — centred on phone screen, no clipping (slide 1 only) ────
          if (page.showLottie)
            Center(
              child: SizedBox(
                width:  160.r,
                height: 160.r,
                child: Lottie.asset(
                  page.lottie,
                  fit: BoxFit.contain,
                  errorBuilder: (_, e, s) => Icon(
                    Icons.explore_rounded,
                    color: page.accentColor,
                    size:  60.sp,
                  ),
                ),
              )
                  .animate(delay: 280.ms)
                  .fade(duration: 500.ms)
                  .scale(begin: const Offset(0.75, 0.75), curve: Curves.easeOutBack),
            ),

        ],
      ),
    );
  }
}


// ── Stacked image cards widget ─────────────────────────────────────────────────

class _StackedCards extends StatelessWidget {
  const _StackedCards({
    required this.images,
    required this.badge,
    required this.accentColor,
  });

  final List<String> images;
  final String       badge;
  final Color        accentColor;

  @override
  Widget build(BuildContext context) {
    const cardW = 160.0;
    const cardH = 210.0;

    return LayoutBuilder(builder: (context, constraints) {
      final cx = constraints.maxWidth / 2;

      return Stack(
        clipBehavior: Clip.none,
        children: [

          // ── Card 3 (back-left, rotated -15°) ──────────────────────────────
          Positioned(
            top:  20.h,
            left: cx - cardW.w * 0.9,
            child: Transform.rotate(
              angle: -15 * pi / 180,
              child: _PhotoCard(
                imagePath:   images[2],
                width:       (cardW * 0.85).w,
                height:      (cardH * 0.85).h,
                accentColor: accentColor,
              ),
            ).animate(delay: 80.ms).fade(duration: 500.ms).scale(
                  begin: const Offset(0.88, 0.88)),
          ),

          // ── Card 2 (back-right, rotated +12°) ────────────────────────────
          Positioned(
            top:   10.h,
            right: cx - cardW.w * 0.9,
            child: Transform.rotate(
              angle: 12 * pi / 180,
              child: _PhotoCard(
                imagePath:   images[1],
                width:       (cardW * 0.88).w,
                height:      (cardH * 0.88).h,
                accentColor: accentColor,
              ),
            ).animate(delay: 120.ms).fade(duration: 500.ms).scale(
                  begin: const Offset(0.88, 0.88)),
          ),

          // ── Card 1 (front, centre, -4°) ───────────────────────────────────
          Positioned(
            top:   40.h,
            left:  cx - cardW.w / 2,
            child: Transform.rotate(
              angle: -4 * pi / 180,
              child: _PhotoCard(
                imagePath:   images[0],
                width:       cardW.w,
                height:      cardH.h,
                accentColor: accentColor,
                badge:       badge,
              ),
            ).animate(delay: 40.ms).fade(duration: 550.ms).scale(
                  begin: const Offset(0.90, 0.90), curve: Curves.easeOutBack),
          ),

        ],
      );
    });
  }
}

// ── Single photo card ─────────────────────────────────────────────────────────

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.accentColor,
    this.badge,
  });

  final String  imagePath;
  final double  width;
  final double  height;
  final Color   accentColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset:     const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit:          BoxFit.cover,
              errorBuilder: (_, e, s) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.6),
                      accentColor.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Icon(Icons.landscape_rounded,
                    color: Colors.white70, size: 36.sp),
              ),
            ),
            // Bottom gradient overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height * 0.45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:  Alignment.topCenter,
                    end:    Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
              ),
            ),
            // Location badge (only on front card)
            if (badge != null)
              Positioned(
                bottom: 12.h,
                left:   10.w,
                right:  10.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color:        Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: Colors.white, size: 11.sp),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          badge!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:      Colors.white,
                            fontSize:   10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bullet row ────────────────────────────────────────────────────────────────

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.text,
    required this.delay,
    required this.accentColor,
  });
  final String   text;
  final Duration delay;
  final Color    accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 44.h),
        child: Container(
          width:   double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color:        accentColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: accentColor.withValues(alpha: 0.18)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                fontSize:   12.5.sp,
                fontWeight: FontWeight.w600,
                color:      AppColors.textPrimary,
                height:     1.4,
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: delay).fade(duration: 400.ms).slideX(begin: 0.06, end: 0);
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.isLast,
    required this.accent,
    required this.onNext,
    required this.onSkip,
  });
  final int currentPage, totalPages;
  final bool isLast;
  final Color accent;
  final VoidCallback onNext, onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 36.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset:     const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve:    Curves.easeOutCubic,
                margin:   EdgeInsets.symmetric(horizontal: 4.w),
                width:    active ? 24.w : 8.w,
                height:   8.h,
                decoration: BoxDecoration(
                  color:        active ? accent : AppColors.divider,
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),

          SizedBox(height: 18.h),

          // CTA button
          GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width:   double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.80)],
                  begin:  Alignment.centerLeft,
                  end:    Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color:      accent.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset:     const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'Get Started' : 'Next',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   15.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    isLast ? Icons.explore_rounded : Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          if (!isLast)
            GestureDetector(
              onTap: onSkip,
              child: Text(
                'Skip for now',
                style: TextStyle(
                  color:      AppColors.textSecondary,
                  fontSize:   13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
