import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/notification_repository.dart';

class BellBadge extends StatefulWidget {
  final NotificationScope scope;
  final Widget child;
  const BellBadge({super.key, required this.scope, required this.child});

  @override
  State<BellBadge> createState() => _BellBadgeState();
}

class _BellBadgeState extends State<BellBadge> {
  Stream<int>? _stream;

  @override
  void initState() {
    super.initState();
    final uid = Get.find<AuthRepository>().currentUid;
    if (uid != null) {
      final repo = Get.find<NotificationRepository>();
      final path = widget.scope == NotificationScope.admin
          ? repo.hostelPath(uid)
          : repo.userPath(uid);
      _stream = repo.watchUnreadCount(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = _stream;
    if (stream == null) return widget.child;

    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snap) {
        final n = snap.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (n > 0)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    n >= 10 ? '9+' : '$n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}