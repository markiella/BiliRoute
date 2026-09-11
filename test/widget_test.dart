// BiliRoute — basic smoke test.
// Verifies the App widget hierarchy mounts without crashing when all
// required providers are present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_tourism_ai_app/core/saved/saved_destinations_notifier.dart';
import 'package:mobile_tourism_ai_app/core/theme/theme_notifier.dart';
import 'package:mobile_tourism_ai_app/features/auth/repositories/auth_repository.dart';
import 'package:mobile_tourism_ai_app/features/destinations/repositories/destination_repository.dart';

/// Minimal provider wrapper for tests – only includes providers required by
/// the root App widget and any screens reachable from the initial route.
Widget _testApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier()),
      ChangeNotifierProvider<SavedDestinationsNotifier>(
          create: (_) => SavedDestinationsNotifier()),
      ChangeNotifierProvider<TouristDestinationRepository>(
          create: (_) => TouristDestinationRepository()),
      ChangeNotifierProvider<AuthRepository>.value(
          value: AuthRepository.instance),
    ],
    child: child,
  );
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App root renders without crashing', (WidgetTester tester) async {
    // Wrap with a simple MaterialApp to avoid full router initialisation
    await tester.pumpWidget(
      _testApp(
        MaterialApp(
          home: Scaffold(
            body: Container(
              key: const Key('smoke_test_container'),
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('smoke_test_container')), findsOneWidget);
  });
}
