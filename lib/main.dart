import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'admin/data/repositories/admin_auth_repository.dart';
import 'admin/data/repositories/advisory_repository.dart';
import 'admin/data/repositories/destination_repository.dart';
import 'admin/data/repositories/field_survey_repository.dart';
import 'admin/data/repositories/gallery_repository.dart';
import 'admin/data/repositories/provider_repository.dart';
import 'admin/data/repositories/recommendation_settings_repository.dart';
import 'admin/data/repositories/route_repository.dart';
import 'admin/data/repositories/schedule_repository.dart';
import 'admin/data/repositories/user_repository.dart';
import 'app.dart';
import 'core/saved/saved_destinations_notifier.dart';
import 'core/theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted theme before the first frame
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadSavedTheme();

  // Load persisted saved destinations
  final savedNotifier = SavedDestinationsNotifier();
  await savedNotifier.loadSaved();

  runApp(
    MultiProvider(
      providers: [
        // ── Theme ────────────────────────────────────────────────────────────
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),

        // ── Saved Destinations ────────────────────────────────────────────────
        ChangeNotifierProvider<SavedDestinationsNotifier>.value(value: savedNotifier),

        // ── Core repositories (tourist app + admin portal) ───────────────────
        ChangeNotifierProvider(create: (_) => DestinationRepository()),
        ChangeNotifierProvider(create: (_) => RouteRepository()),
        ChangeNotifierProvider(create: (_) => ProviderRepository()),
        ChangeNotifierProvider(create: (_) => AdvisoryRepository()),
        ChangeNotifierProvider(create: (_) => ScheduleRepository()),
        ChangeNotifierProvider(create: (_) => GalleryRepository()),

        // ── Research & Intelligence repositories ────────────────────────────
        ChangeNotifierProvider(create: (_) => FieldSurveyRepository()),
        ChangeNotifierProvider(create: (_) => RecommendationSettingsRepository()),

        // ── User management ─────────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => UserRepository()),

        // ── Admin authentication ─────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => AdminAuthRepository()),
      ],
      child: const App(),
    ),
  );
}
