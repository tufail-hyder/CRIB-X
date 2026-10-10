import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constant/date_text.dart';
import '../../../../core/exceptions/exception_handler.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/complaint_model.dart';
import '../../../../data/models/dashboard_stats_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/models/room_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/complaint_repository.dart';
import '../../../../data/repositories/payment_repository.dart';
import '../../../../data/repositories/room_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../shared/popups/app_snackbar.dart';

enum ReportPeriod {
  thisMonth,
  lastMonth,
  last3Months,
  thisYear;

  String get label {
    switch (this) {
      case ReportPeriod.thisMonth:
        return 'This Month';
      case ReportPeriod.lastMonth:
        return 'Last Month';
      case ReportPeriod.last3Months:
        return 'Last 3 Months';
      case ReportPeriod.thisYear:
        return 'This Year';
    }
  }

  /// [from, to) : to shamil nahi
  (DateTime, DateTime) range(DateTime now) {
    switch (this) {
      case ReportPeriod.thisMonth:
        return (DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 1));
      case ReportPeriod.lastMonth:
        return (DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 1));
      case ReportPeriod.last3Months:
        return (DateTime(now.year, now.month - 2, 1), DateTime(now.year, now.month + 1, 1));
      case ReportPeriod.thisYear:
        return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
    }
  }
}

class MethodShare {
  final PaymentMethod method;
  final double amount;
  final double share; // 0..1
  const MethodShare(this.method, this.amount, this.share);
}

class SeaterOccupancy {
  final int seater;
  final int totalBeds;
  final int occupiedBeds;
  const SeaterOccupancy(this.seater, this.totalBeds, this.occupiedBeds);

  double get ratio => totalBeds == 0 ? 0 : occupiedBeds / totalBeds;
}

class CategoryCount {
  final ComplaintCategory category;
  final int count;
  const CategoryCount(this.category, this.count);
}

class ReportsController extends GetxController {
  final PaymentRepository _payments;
  final ComplaintRepository _complaints;
  final StudentRepository _studentRepo;
  final RoomRepository _roomRepo;
  final AuthRepository _auth;
  ReportsController(this._payments, this._complaints, this._studentRepo,
      this._roomRepo, this._auth);

  final period = ReportPeriod.thisMonth.obs;

  // Period ke hisab se (one-shot)
  final payments = <PaymentModel>[].obs;
  final complaints = <ComplaintModel>[].obs;

  // Abhi ki halat (live)
  final students = <StudentModel>[].obs;
  final rooms = <RoomModel>[].obs;

  final isLoading = true.obs;
  final errorMessage = RxnString();

  StreamSubscription<List<StudentModel>>? _studentSub;
  StreamSubscription<List<RoomModel>>? _roomSub;
  int _loadId = 0;

  @override
  void onReady() {
    super.onReady();
    final uid = _auth.currentUid ?? '';
    _studentSub = _studentRepo
        .watchStudents(uid)
        .listen(students.assignAll, onError: (_) {});
    _roomSub =
        _roomRepo.watchRooms(uid).listen(rooms.assignAll, onError: (_) {});
    load();
  }

  void setPeriod(ReportPeriod p) {
    if (p == period.value) return;
    period.value = p;
    load();
  }

  Future<void> load() async {
    final id = ++_loadId; // tez tez period badalne par purana jawab na likhe
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await NetworkManager.instance.ensureConnected();

      final uid = _auth.currentUid ?? '';
      final r = period.value.range(DateTime.now());
      final p = await _payments.fetchPayments(uid, from: r.$1, to: r.$2);
      final c = await _complaints.fetchComplaints(uid, from: r.$1, to: r.$2);

      if (id != _loadId) return;
      payments.assignAll(p);
      complaints.assignAll(c);
    } catch (e, s) {
      if (id != _loadId) return;
      errorMessage.value = ExceptionHandler.message(e, s);
    } finally {
      if (id == _loadId) isLoading.value = false;
    }
  }

  // =================== Summary ===================
  double get revenue => payments.fold(0.0, (sum, p) => sum + p.amount);

  String get _currentMonthKey => StudentModel.monthKey(DateTime.now());

  List<StudentModel> get activeStudents =>
      students.where((s) => s.isActive).toList();

  /// Is mahine ki baqi fees (abhi ki halat, period se alag)
  double get outstandingFees => activeStudents.fold(
      0.0, (sum, s) => sum + s.remainingFor(_currentMonthKey));

  /// Sab se zyada baqi wale students (top 5)
  List<StudentModel> get topOutstanding {
    final list = activeStudents
        .where((s) => s.remainingFor(_currentMonthKey) > 0)
        .toList()
      ..sort((a, b) => b
          .remainingFor(_currentMonthKey)
          .compareTo(a.remainingFor(_currentMonthKey)));
    return list.take(5).toList();
  }

  int get outstandingCount => activeStudents
      .where((s) => s.remainingFor(_currentMonthKey) > 0)
      .length;

  int get newCheckIns {
    final r = period.value.range(DateTime.now());
    return students
        .where((s) =>
    !s.checkInDate.isBefore(r.$1) && s.checkInDate.isBefore(r.$2))
        .length;
  }

  int get totalBeds => rooms.fold(0, (sum, r) => sum + r.totalBeds);
  int get occupiedBeds => rooms.fold(0, (sum, r) => sum + r.occupiedBeds);
  int get occupancyPercent =>
      totalBeds == 0 ? 0 : (occupiedBeds / totalBeds * 100).round();

  // =================== Revenue chart ===================
  /// Ek mahine ka period = hafta-wari, warna mahina-wari
  List<IncomePoint> get revenuePoints {
    final r = period.value.range(DateTime.now());

    if (period.value == ReportPeriod.thisMonth ||
        period.value == ReportPeriod.lastMonth) {
      final days = DateTime(r.$1.year, r.$1.month + 1, 0).day;
      final weeks = (days / 7).ceil();
      final sums = List<double>.filled(weeks, 0);
      for (final p in payments) {
        final i = ((p.paidAt.day - 1) ~/ 7).clamp(0, weeks - 1).toInt();
        sums[i] += p.amount;
      }
      return [for (var i = 0; i < weeks; i++) IncomePoint('W${i + 1}', sums[i])];
    }

    final months = <DateTime>[];
    for (var m = r.$1; m.isBefore(r.$2); m = DateTime(m.year, m.month + 1, 1)) {
      months.add(m);
    }
    return [
      for (final m in months)
        IncomePoint(
          monthShort(m),
          payments
              .where((p) => p.paidAt.year == m.year && p.paidAt.month == m.month)
              .fold(0.0, (sum, p) => sum + p.amount),
        ),
    ];
  }

  // =================== Payment methods ===================
  List<MethodShare> get methodShares {
    final total = revenue;
    final sums = <PaymentMethod, double>{};
    for (final p in payments) {
      sums[p.method] = (sums[p.method] ?? 0) + p.amount;
    }
    final list = sums.entries
        .map((e) => MethodShare(e.key, e.value, total == 0 ? 0 : e.value / total))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  // =================== Occupancy by room type ===================
  List<SeaterOccupancy> get occupancyBySeater {
    final total = <int, int>{};
    final occupied = <int, int>{};
    for (final r in rooms) {
      total[r.seater] = (total[r.seater] ?? 0) + r.totalBeds;
      occupied[r.seater] = (occupied[r.seater] ?? 0) + r.occupiedBeds;
    }
    final keys = total.keys.toList()..sort();
    return [for (final k in keys) SeaterOccupancy(k, total[k]!, occupied[k] ?? 0)];
  }

  // =================== Complaints ===================
  int get complaintsTotal => complaints.length;
  int get complaintsResolved => complaints.where((c) => c.isResolved).length;
  int get complaintsOpen => complaintsTotal - complaintsResolved;

  String get avgResolution {
    final done =
    complaints.where((c) => c.isResolved && c.resolvedAt != null).toList();
    if (done.isEmpty) return '—';
    final hours = done.fold<double>(
        0, (sum, c) => sum + c.resolvedAt!.difference(c.createdAt).inMinutes / 60) /
        done.length;
    return hours < 24
        ? '${hours.toStringAsFixed(0)} hrs'
        : '${(hours / 24).toStringAsFixed(1)} days';
  }

  List<CategoryCount> get complaintsByCategory {
    final counts = <ComplaintCategory, int>{};
    for (final c in complaints) {
      counts[c.category] = (counts[c.category] ?? 0) + 1;
    }
    final list = counts.entries.map((e) => CategoryCount(e.key, e.value)).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list;
  }

  // =================== Copy summary ===================
  Future<void> copySummary() async {
    final r = period.value.range(DateTime.now());
    final to = r.$2.subtract(const Duration(days: 1));
    final b = StringBuffer()
      ..writeln('Hostel Report: ${period.value.label}')
      ..writeln('${dateText(r.$1)} - ${dateText(to)}')
      ..writeln()
      ..writeln('Revenue collected: ${Formatters.currency(revenue)}')
      ..writeln('Outstanding fees (this month): ${Formatters.currency(outstandingFees)}')
      ..writeln('New check-ins: $newCheckIns')
      ..writeln('Bed occupancy: $occupancyPercent% ($occupiedBeds/$totalBeds)')
      ..writeln()
      ..writeln('Payment methods:');
    for (final m in methodShares) {
      b.writeln('- ${m.method.label}: ${Formatters.currency(m.amount)}');
    }
    b
      ..writeln()
      ..writeln('Complaints: $complaintsTotal (resolved $complaintsResolved, open $complaintsOpen)')
      ..writeln('Average resolution time: $avgResolution');

    await Clipboard.setData(ClipboardData(text: b.toString()));
    AppSnackbar.success('Report summary copied');
  }

  @override
  void onClose() {
    _studentSub?.cancel();
    _roomSub?.cancel();
    super.onClose();
  }
}