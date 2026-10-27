import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constant/app_sizes.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({super.key});

  Future<void> _logout() async {
    await Get.find<AuthRepository>().logout();
    Get.offAllNamed(AppRoutes.studentLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRIB X')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: FutureBuilder<UserModel?>(
            future: Get.find<AuthRepository>().getCurrentUser(),
            builder: (context, snap) {
              final name = snap.data?.name ?? '';
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name.isEmpty ? 'Welcome!' : 'Welcome, $name!',
                      style: AppTextStyles.sectionInnerTitle),
                  AppSizes.hSm,
                  Text('Student dashboard is coming next.',
                      style: AppTextStyles.body),
                  AppSizes.hLg,
                  SizedBox(
                    width: 180,
                    child: PrimaryButton(text: 'Log out', onPressed: _logout),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}