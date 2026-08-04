// BiliPlan — basic smoke test.
// This is a placeholder test that verifies the App widget mounts without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_tourism_ai_app/app.dart';

void main() {
  testWidgets('App mounts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    // Verify the app builds at all (no assertion errors).
    expect(find.byType(App), findsOneWidget);
  });
}
