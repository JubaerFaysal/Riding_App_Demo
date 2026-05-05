import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:get/get.dart';
import 'package:riding_app/routes/app_routes.dart';

import 'core/bindings/controller_binder.dart';
import 'core/localization/app_translations.dart';


class PlatformUtils {
  static bool get isIOS =>
      foundation.defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid =>
      foundation.defaultTargetPlatform == TargetPlatform.android;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoute.home,
          initialBinding: ControllerBinder(),
          getPages: AppRoute.routes,
          themeMode: ThemeMode.system,
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
        );

  }

  // ThemeData _getLightTheme() {
  //   return PlatformUtils.isIOS
  //       ? AppTheme.lightTheme.copyWith(platform: TargetPlatform.iOS)
  //       : AppTheme.lightTheme;
  // }
  //
  // ThemeData _getDarkTheme() {
  //   return PlatformUtils.isIOS
  //       ? AppTheme.darkTheme.copyWith(platform: TargetPlatform.iOS)
  //       : AppTheme.darkTheme;
  // }
}
