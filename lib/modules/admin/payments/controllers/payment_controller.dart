import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/dashboard_stats_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/payment_repository.dart';
import '../../../../data/repositories/student_repository.dart';

class PaymentsController extends GetxController {
  final PaymentRepository _repo;
  final StudentRepository _studentRepo;
  final AuthRepository _auth;
  PaymentsController(this._repo, this._studentRepo, this._auth);

  static const chartMonths = 6;

  final students = <StudentModel>[].obs;
  final payments = <PaymentModel>[].obs;

  /// null = All
  final filter = Rxn<PaymentStatus>();

  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<StudentModel>>? _studentSub;
  StreamSubscription<List<PaymentModel>>? _paymentSub;

  @override
  void onReady() {
    super.onReady();
    listen();
  }

  void listen() {
    final uid = _auth.currentUid ?? '';
    final now = DateTime.now();
    final since = DateTime(now.year, now.month - (chartMonths - 1), 1);

    isLoading.value = true;
    errorMessage.value = null;

    _studentSub?.cancel();
    _studentSub = _studentRepo.watchStudents(uid).listen(
          (list) {
        students.assignAll(list);
        isLoading.value = false;
      },
      onError: (e, s) {
        errorMessage.value = ExceptionHandler.message(e, s);
        isLoading.value = false;
      },
    );

    _paymentSub?.cancel();
    _paymentSub = _repo.watchPayments(uid, since: since).listen(
      payments.assignAll,
      onError: (e, s) {
        errorMessage.value = ExceptionHandler.message(e, s);
        isLoading.value = false;
      },
    );
  }

  /// Sirf rehne wale students (left wale nahi)
  List<StudentModel> get activeStudents =>
      students.where((s) => s.isActive).toList();

  List<StudentModel> get filtered => activeStudents
      .where((s) => filter.value == null || s.paymentStatus == filter.value)
      .toList();

  // ---- Stats ----
  int _count(PaymentStatus st) =>
      activeStudents.where((s) => s.paymentStatus == st).length;

  int get paidCount => _count(PaymentStatus.paid);
  int get pendingCount => _count(PaymentStatus.pending);
  int get overdueCount => _count(PaymentStatus.due);

  double get monthRevenue {
    final now = DateTime.now();
    return payments
        .where((p) => p.paidAt.year == now.year && p.paidAt.month == now.month)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Monthly Revenue chart: aakhri 6 mahine
  List<IncomePoint> get revenuePoints {
    final now = DateTime.now();
    return [
      for (var i = chartMonths - 1; i >= 0; i--)
            () {
          final m = DateTime(now.year, now.month - i, 1);
          final total = payments
              .where((p) => p.paidAt.year == m.year && p.paidAt.month == m.month)
              .fold(0.0, (sum, p) => sum + p.amount);
          return IncomePoint(monthShort(m), total);
        }(),
    ];
  }

  /// Student pass karo to form me pehle se select hoga
  void openRecord([StudentModel? student]) =>
      Get.toNamed(AppRoutes.paymentForm, arguments: student);

  @override
  void onClose() {
    _studentSub?.cancel();
    _paymentSub?.cancel();
    super.onClose();
  }
}