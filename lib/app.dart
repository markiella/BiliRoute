import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/preferences/user_preferences_notifier.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'l10n/app_localizations.dart';

/// Root widget of BiliRoute.
///
/// Listens to:
///   • [ThemeNotifier]           — dark / light / system theme
///   • [UserPreferencesNotifier] — locale (language) + font size (textScaler)
///
/// The [MediaQuery] builder override propagates the user's selected text scale
/// factor through the entire widget tree without needing to touch individual
/// widget font sizes.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Base design size: iPhone 14 Pro (390 × 844)
      designSize: const Size(390, 844),
      minTextAdapt:    true,
      splitScreenMode: true,
      builder: (context, child) {
        final themeNotifier = context.watch<ThemeNotifier>();
        final prefs         = context.watch<UserPreferencesNotifier>();

        return MaterialApp.router(
          title:                      AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme:                      AppTheme.lightTheme,
          darkTheme:                  AppTheme.darkTheme,
          themeMode:                  themeNotifier.mode,

          // ── Localization ──────────────────────────────────────────────────
          locale:                     prefs.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales:           UserPreferencesNotifier.supportedLocales,

          // ── Global font-size scaling ───────────────────────────────────────
          // Wraps every screen in a MediaQuery that overrides textScaler so
          // ALL Text widgets in the app honour the user's accessibility choice.
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(prefs.textScaleFactor),
              ),
              child: child!,
            );
          },

          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
