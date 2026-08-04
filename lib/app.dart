import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';

/// Root widget of BiliRoute.
/// Listens to [ThemeNotifier] so the theme updates immediately without restart.
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
        return MaterialApp.router(
          title:                   AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme:                   AppTheme.lightTheme,
          darkTheme:               AppTheme.darkTheme,
          themeMode:               themeNotifier.mode,
          // AnimatedTheme handles 300 ms color transitions automatically
          // when themeMode changes.
          routerConfig:            AppRouter.router,
        );
      },
    );
  }
}
