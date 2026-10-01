import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../shared/widgets/app_bar/custom_app_bar.dart';
import 'admin_drawer.dart';

class AdminScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.floatingActionButton,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: AppColors.scaffoldBg,
      appBar: CustomAppBar(
        title: widget.title,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _key.currentState?.openDrawer(),
        ),
        actions: [
          ...widget.actions,
          const AppBarIconButton(icon: Icons.notifications_none_rounded),
        ],
      ),
      drawer: const AdminDrawer(),
      floatingActionButton: widget.floatingActionButton,
      body: widget.body,
    );
  }
}