import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/binding/initial_binding.dart';
import 'core/constant/app_strings.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/connectivity_banner.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.adminLogin,
      getPages: AppPages.pages,
      builder: (context, child) => ConnectivityBanner(child: child!),
    );//
  }
}