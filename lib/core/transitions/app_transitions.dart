import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralised page-transition builders for BiliRoute.
///
/// All transitions are intentionally cinematic — smooth easing, layered fades,
/// and subtle scaling to reinforce the "one continuous journey" UX.
class AppTransitions {
  AppTransitions._();

  // ── Shared durations ──────────────────────────────────────────────────────

  static const _fast   = Duration(milliseconds: 320);
  static const _normal = Duration(milliseconds: 480);
  static const _slow   = Duration(milliseconds: 620);

  // ── Page builders ─────────────────────────────────────────────────────────

  /// Cinematic fade + subtle scale-up.
  /// Used for: home, route-selection entrance, categories.
  static Page<T> fadeScale<T>(
    GoRouterState state,
    Widget child, {
    Duration duration = _normal,
  }) {
    return CustomTransitionPage<T>(
      key:             state.pageKey,
      child:           child,
      transitionDuration:        duration,
      reverseTransitionDuration: _fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade  = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scale = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final exitFade = Tween<double>(begin: 1.0, end: 0.85).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
        );
        return FadeTransition(
          opacity: exitFade,
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
    );
  }

  /// Slide up from bottom — used for route-selection (bottom-sheet feel).
  static Page<T> slideUp<T>(
    GoRouterState state,
    Widget child, {
    Duration duration = _normal,
  }) {
    return CustomTransitionPage<T>(
      key:             state.pageKey,
      child:           child,
      transitionDuration:        duration,
      reverseTransitionDuration: _fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 0.08),
          end:   Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Cinematic dissolve — smooth cross-fade without scale.
  /// Used for: generating → itinerary result (rewarding reveal).
  static Page<T> dissolve<T>(
    GoRouterState state,
    Widget child, {
    Duration duration = _slow,
  }) {
    return CustomTransitionPage<T>(
      key:             state.pageKey,
      child:           child,
      transitionDuration:        duration,
      reverseTransitionDuration: _fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return FadeTransition(opacity: fade, child: child);
      },
    );
  }

  /// Collapse inward — for route-selection → generating (folding feel).
  static Page<T> collapseIn<T>(
    GoRouterState state,
    Widget child, {
    Duration duration = _normal,
  }) {
    return CustomTransitionPage<T>(
      key:             state.pageKey,
      child:           child,
      transitionDuration:        duration,
      reverseTransitionDuration: _fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade  = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scale = Tween<double>(begin: 1.04, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }
}
