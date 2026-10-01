import 'package:flutter/material.dart';
import '../../../shared/widgets/empty_state.dart';
import 'admin_scaffold.dart';

class ComingSoonView extends StatelessWidget {
  final String title;
  const ComingSoonView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: title,
      body: EmptyState(
        icon: Icons.construction_rounded,
        title: '$title coming soon',
      ),
    );
  }
}