import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/complaint_model.dart';
import '../../../../data/models/dashboard_stats_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/complaint_repository.dart';
import '../../../../shared/popups/app_dialogs.dart';
import '../../../../shared/popups/app_snackbar.dart';
import '../widgets/complaints_action_menu.dart';
import '../widgets/complaints_dialogue_box.dart';
import '../widgets/update_complaint_status_dialog.dart';

class ComplaintsController extends GetxController {
  final ComplaintRepository _repo;
  final AuthRepository _auth;
  ComplaintsController(this._repo, this._auth);

  static const chartCategories = 6;

  final complaints = <ComplaintModel>[].obs;

  final categoryFilter = Rxn<ComplaintCategory>(); // "Issues" chips
  final statusFilter = Rxn<ComplaintStatus>();
  final priorityFilter = Rxn<ComplaintPriority>();

  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<ComplaintModel>>? _sub;

  @override
  void onReady() {
    super.onReady();
    listen();
  }

  void listen() {
    isLoading.value = true;
    errorMessage.value = null;
    _sub?.cancel();
    _sub = _repo.watchComplaints(_auth.currentUid ?? '').listen(
          (list) {
        complaints.assignAll(list);
        isLoading.value = false;
      },
      onError: (e, s) {
        errorMessage.value = ExceptionHandler.message(e, s);
        isLoading.value = false;
      },
    );
  }

  List<ComplaintModel> get filtered => complaints.where((c) {
    if (categoryFilter.value != null && c.category != categoryFilter.value) {
      return false;
    }
    if (statusFilter.value != null && c.status != statusFilter.value) {
      return false;
    }
    if (priorityFilter.value != null && c.priority != priorityFilter.value) {
      return false;
    }
    return true;
  }).toList();

  // ---- Stats ----
  int get total => complaints.length;
  int get openCount => complaints.where((c) => c.isOpen).length;
  int get inProgressCount => complaints.where((c) => c.isInProgress).length;
  int get resolvedCount => complaints.where((c) => c.isResolved).length;

  /// Chart: sab se zyada complaints wali 6 categories (enum ke tarteeb me)
  List<IncomePoint> get categoryPoints {
    final counts = <ComplaintCategory, int>{
      for (final c in ComplaintCategory.values) c: 0,
    };
    for (final c in complaints) {
      counts[c.category] = counts[c.category]! + 1;
    }

    final top = ComplaintCategory.values.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : a.index.compareTo(b.index);
      });
    final chosen = top.take(chartCategories).toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return [
      for (final c in chosen) IncomePoint(c.label, counts[c]!.toDouble()),
    ];
  }

  void openCreate() => Get.toNamed(AppRoutes.complaintForm);

  void showDetails(ComplaintModel c) =>
      Get.dialog(ComplaintDetailsDialog(complaint: c));

  Future<void> onAction(ComplaintModel c, ComplaintAction action) async {
    switch (action) {
      case ComplaintAction.viewDetails:
        showDetails(c);
        break;
      case ComplaintAction.updateStatus:
        await _updateStatus(c);
        break;
      case ComplaintAction.markResolved:
        await _markResolved(c);
        break;
    }
  }

  Future<void> _updateStatus(ComplaintModel c) async {
    final result = await Get.dialog<StatusUpdate>(
      UpdateComplaintStatusDialog(complaint: c),
    );
    if (result == null) return;

    final hasReply = (result.response ?? '').trim().isNotEmpty;
    if (result.status == c.status && !hasReply) return;

    await _save(c, result.status, response: result.response,
        message: 'Complaint marked as ${result.status.label}');
  }

  Future<void> _markResolved(ComplaintModel c) async {
    if (c.isResolved) {
      AppSnackbar.info('This complaint is already resolved.');
      return;
    }
    final ok = await AppDialogs.confirm(
      title: 'Mark as resolved?',
      message: '${c.shortId} from ${c.studentName} will be marked as resolved.',
      confirmText: 'Resolve',
    );
    if (ok != true) return;

    await _save(c, ComplaintStatus.resolved, message: 'Complaint resolved');
  }

  Future<void> _save(ComplaintModel c, ComplaintStatus status,
      {String? response, required String message}) async {
    try {
      await NetworkManager.instance.ensureConnected();
      await _repo.updateStatus(c, status, response: response);
      AppSnackbar.success(message);
    } catch (e, s) {
      AppSnackbar.error(ExceptionHandler.message(e, s));
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}