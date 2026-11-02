import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/models/setting_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../data/repositories/student_home_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

class NotificationsController extends GetxController {
  final NotificationRepository _repo;
  final AuthRepository _auth;
  final StudentRepository _studentRepo;
  final StudentHomeRepository _homeRepo;
  final NotificationScope scope;

  NotificationsController(
      this._repo,
      this._auth,
      this._studentRepo,
      this._homeRepo,
      this.scope,
      );

  final stored = <NotificationModel>[].obs;

  final derived = <NotificationModel>[].obs;

  final prefs = Rx<NotificationPrefs>(const NotificationPrefs());

  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<NotificationModel>>? _sub;

  bool get isAdmin => scope == NotificationScope.admin;
  String get _uid => _auth.currentUid ?? '';
  String get _path => isAdmin ? _repo.hostelPath(_uid) : _repo.userPath(_uid);

  @override
  void onReady() {
    super.onReady();
    load();
  }

  bool _allowed(NotificationModel n) {
    if (!isAdmin) return true;
    final p = prefs.value;
    switch (n.type) {
      case NotificationType.booking:
        return p.newBooking;
      case NotificationType.rentDue:
        return p.rentDue;
      case NotificationType.complaint:
        return p.complaint;
      default:
        return true;
    }
  }

  List<NotificationModel> get items =>
      [...derived, ...stored.where(_allowed)];

  int get unreadCount => stored.where((n) => !n.isRead && _allowed(n)).length;

  // ------------------------------------------------------------------
  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await NetworkManager.instance.ensureConnected();
    } catch (e, s) {
      errorMessage.value = ExceptionHandler.message(e, s);
      isLoading.value = false;
      return;
    }

    await _sub?.cancel();
    _sub = _repo.watch(_path).listen(
          (list) {
        stored.assignAll(list);
        isLoading.value = false;
      },
      onError: (e, s) {
        errorMessage.value = ExceptionHandler.message(e, s);
        isLoading.value = false;
      },
    );

    await _loadDerived();
  }

  Future<void> _loadDerived() async {
    try {
      if (isAdmin) {
        prefs.value = await _repo.loadAdminPrefs(_uid);
        derived.assignAll(await _adminReminders());
      } else {
        derived.assignAll(await _studentReminders());
      }
    } catch (_) {
      derived.clear();
    }
  }

  Future<List<NotificationModel>> _adminReminders() async {
    if (!prefs.value.rentDue) return [];

    final students = await _studentRepo.watchStudents(_uid).first;
    final key = StudentModel.monthKey(DateTime.now());
    final overdue = students
        .where((s) => s.isActive && s.paymentStatus == PaymentStatus.due)
        .toList();
    if (overdue.isEmpty) return [];

    final total = overdue.fold<double>(0, (sum, s) => sum + s.remainingFor(key));
    final n = overdue.length;
    return [
      NotificationModel(
        id: 'derived-rent-overdue',
        type: NotificationType.rentDue,
        title: 'Rent overdue',
        body:
        '$n student${n == 1 ? ' has' : 's have'} overdue rent'
            '${total > 0 ? ' (${Formatters.currency(total)} unpaid)' : ''}.',
        createdAt: DateTime.now(),
        isRead: true,
        isDerived: true,
      ),
    ];
  }

  Future<List<NotificationModel>> _studentReminders() async {
    final stay = await _homeRepo.fetchMyStay(_uid);
    if (stay == null) return [];

    final now = DateTime.now();
    final key = StudentModel.monthKey(now);
    final left = stay.remainingFor(key);
    final status = stay.paymentStatus;
    final leftText = left > 0 ? ' Remaining: ${Formatters.currency(left)}.' : '';

    if (status == PaymentStatus.due) {
      return [
        NotificationModel(
          id: 'derived-rent-overdue',
          type: NotificationType.rentDue,
          title: 'Your rent is overdue',
          body: 'Please pay your hostel rent as soon as possible.$leftText',
          createdAt: now,
          isRead: true,
          isDerived: true,
        ),
      ];
    }

    if (status == PaymentStatus.pending) {
      final due = DateTime(now.year, now.month, StudentModel.dueDay);
      final days = due.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (days >= 0 && days <= 3) {
        return [
          NotificationModel(
            id: 'derived-rent-soon',
            type: NotificationType.rentDue,
            title: 'Rent due ${days == 0 ? 'today' : 'on ${dateText(due)}'}',
            body: 'Your hostel rent is due soon.$leftText',
            createdAt: now,
            isRead: true,
            isDerived: true,
          ),
        ];
      }
    }
    return [];
  }

  // ------------------------------------------------------------------
  Future<void> markRead(NotificationModel n) async {
    if (n.isDerived || n.isRead) return;
    try {
      await _repo.markRead(_path, n.id);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  Future<void> markAllRead() async {
    final ids = stored.where((n) => !n.isRead).map((n) => n.id).toList();
    if (ids.isEmpty) return;
    try {
      await _repo.markAllRead(_path, ids);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  Future<void> open(NotificationModel n) async {
    await markRead(n);
    if (!isAdmin) return;

    switch (n.type) {
      case NotificationType.booking:
        Get.toNamed(AppRoutes.adminBookings);
        break;
      case NotificationType.rentDue:
        Get.toNamed(AppRoutes.adminPayments);
        break;
      case NotificationType.complaint:
        Get.toNamed(AppRoutes.adminComplaints);
        break;
      default:
        break;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}