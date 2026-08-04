import 'package:go_router/go_router.dart';

import '../../data/models/destination_model.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/destinations/details/destination_details_screen.dart';
import '../../features/home/pages/category_list_page.dart';
import '../../features/home/pages/destinations_list_page.dart';
import '../../features/itinerary/edit/edit_itinerary_screen.dart';
import '../../features/itinerary/generating/generating_screen.dart';
import '../../features/itinerary/result/itinerary_result_screen.dart';
import '../../features/itinerary/route_selection/route_selection_screen.dart';
import '../../features/map/map_preview_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/profile/saved_destinations_screen.dart';
import '../../navigation/main_navigation.dart';
import '../transitions/app_transitions.dart';
import '../transitions/transition_data.dart';

/// Centralised navigation configuration for BiliRoute.
///
/// Route hierarchy:
///   /          → WelcomeScreen (onboarding)
///   /home      → MainNavigation (tab shell — tabs handle Plan/Map/Fare/Safety)
///   /route-selection → RouteSelectionScreen  (pushed over shell)
///   /generating      → GeneratingScreen      (pushed over shell)
///   /itinerary-result → ItineraryResultScreen (pushed over shell)
///   /edit-itinerary   → EditItineraryScreen   (pushed over shell)
///
/// All full-screen routes use [AppTransitions] for cinematic page transitions.
/// The [TransitionPayload] is passed via GoRouter `extra` to share the hero
/// image tag and destination metadata across the flow.
class AppRouter {
  AppRouter._(); // prevent instantiation

  // ── Route path constants ─────────────────────────────────────────────────
  static const String welcome            = '/';
  static const String home               = '/home';
  static const String login              = '/login';
  static const String register           = '/register';
  static const String generating         = '/generating';
  static const String routeSelection     = '/route-selection';
  static const String itineraryResult    = '/itinerary-result';
  static const String editItinerary      = '/edit-itinerary';
  static const String categories         = '/categories';
  static const String destinations       = '/destinations';
  static const String destinationDetails = '/destination-details';
  static const String savedDestinations  = '/saved-destinations';

  // ── Default fallback payload (for direct navigation / deep links) ────────
  static TransitionPayload _payloadFromExtra(GoRouterState state) {
    final extra = state.extra;
    if (extra is TransitionPayload) return extra;
    // Fallback: derive from query params
    final dest = state.uri.queryParameters['destination'] ?? 'Sambawan Island';
    return TransitionPayload(
      destinationName: dest,
      heroTag:         'dest_image_${dest.toLowerCase().replaceAll(' ', '_')}',
      imageAsset:      null,
    );
  }

  /// Singleton router instance shared across the app.
  static final GoRouter router = GoRouter(
    initialLocation: welcome,
    debugLogDiagnostics: false,
    routes: [

      // ── Onboarding (3-page swipe flow) ─────────────────────────────────
      GoRoute(
        path: welcome,
        name: 'onboarding',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          state,
          const OnboardingScreen(),
        ),
      ),

      // ── Legacy single-page welcome (kept for reference) ──────────────────
      GoRoute(
        path: '/welcome-classic',
        name: 'welcome-classic',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          state,
          const WelcomeScreen(),
        ),
      ),

      // ── Auth screens ─────────────────────────────────────────────────────
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          state,
          const LoginScreen(),
        ),
      ),

      GoRoute(
        path: register,
        name: 'register',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          state,
          const RegisterScreen(),
        ),
      ),

      // ── Main shell (contains tab screens as IndexedStack) ────────────────
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          state,
          const MainNavigation(),
          duration: const Duration(milliseconds: 560),
        ),
      ),

      // ── Route Selection (slide-up, destination image Hero active) ────────
      GoRoute(
        path: routeSelection,
        name: 'route-selection',
        pageBuilder: (context, state) {
          final payload = _payloadFromExtra(state);
          return AppTransitions.slideUp(
            state,
            RouteSelectionScreen(
              destination: payload.destinationName,
              payload:     payload,
            ),
          );
        },
      ),

      // ── Generating (collapse-in, continuing from route selection) ────────
      GoRoute(
        path:    generating,
        name:    'generating',
        pageBuilder: (context, state) {
          final payload = state.extra is TransitionPayload
              ? state.extra as TransitionPayload
              : null;
          return AppTransitions.collapseIn(
            state,
            GeneratingScreen(payload: payload),
          );
        },
      ),

      // ── Itinerary Result (cinematic dissolve reveal) ─────────────────────
      GoRoute(
        path:    itineraryResult,
        name:    'itinerary-result',
        pageBuilder: (context, state) {
          final payload = state.extra is TransitionPayload
              ? state.extra as TransitionPayload
              : null;
          return AppTransitions.dissolve(
            state,
            ItineraryResultScreen(payload: payload),
          );
        },
      ),

      GoRoute(
        path: editItinerary,
        name: 'edit-itinerary',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          state,
          const EditItineraryScreen(),
        ),
      ),

      // ── MapPreviewScreen as full-screen overlay ──────────────────────────
      GoRoute(
        path: '/map-preview',
        name: 'map-preview',
        pageBuilder: (context, state) => AppTransitions.fadeScale(
          state,
          const MapPreviewScreen(),
        ),
      ),

      // ── Browse pages pushed over the tab shell ──────────────────────────
      GoRoute(
        path:    categories,
        name:    'categories',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          state,
          const CategoryListPage(),
        ),
      ),
      GoRoute(
        path:    destinations,
        name:    'destinations',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          state,
          const DestinationsListPage(),
        ),
      ),

      // ── Destination Details (hero slide-up from card) ────────────────────
      GoRoute(
        path:    destinationDetails,
        name:    'destination-details',
        pageBuilder: (context, state) {
          final item = state.extra as DestinationItem;
          return AppTransitions.slideUp(state, DestinationDetailsScreen(item: item));
        },
      ),

      // ── Saved Destinations ────────────────────────────────────────────────
      GoRoute(
        path:    savedDestinations,
        name:    'saved-destinations',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          state,
          const SavedDestinationsScreen(),
        ),
      ),
    ],
  );
}
