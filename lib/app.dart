import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constant/app_strings.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/connectivity_banner.dart';

class App extends StatelessWidget {
  final String initialRoute;
  const App({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
      builder: (context, child) => ConnectivityBanner(child: child!),
    );
  }
}