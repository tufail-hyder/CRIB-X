import 'dart:async';
import '../../core/constant/date_text.dart';
import '../models/dashboard_stats_model.dart';
import '../models/payment_model.dart';
import '../models/room_model.dart';
import '../models/student_model.dart';
import 'payment_repository.dart';
import 'room_repository.dart';
import 'student_repository.dart';

class DashboardRepository {
  final RoomRepository _rooms;
  final StudentRepository _students;
  final PaymentRepository _payments;
  DashboardRepository(this._rooms, this._students, this._payments);

  static const chartMonths = 6;
  static const recentCount = 5;

  Stream<DashboardStats> watchStats(String hostelId) {
    final now = DateTime.now();
    final since = DateTime(now.year, now.month - (chartMonths - 1), 1);

    List<RoomModel>? rooms;
    List<StudentModel>? students;
    List<PaymentModel>? payments;
    final subs = <StreamSubscription<dynamic>>[];
    late final StreamController<DashboardStats> out;

    void emit() {
      final r = rooms, s = students, p = payments;
      if (r == null || s == null || p == null || out.isClosed) return;
      out.add(_build(r, s, p));
    }

    out = StreamController<DashboardStats>(
      onListen: () {
        subs.add(_rooms.watchRooms(hostelId).listen((v) {
          rooms = v;
          emit();
        }, onError: out.addError));
        subs.add(_students.watchStudents(hostelId).listen((v) {
          students = v;
          emit();
        }, onError: out.addError));
        subs.add(_payments.watchPayments(hostelId, since: since).listen((v) {
          payments = v;
          emit();
        }, onError: out.addError));
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
        subs.clear();
      },
    );
    return out.stream;
  }

  DashboardStats _build(
      List<RoomModel> rooms,
      List<StudentModel> students,
      List<PaymentModel> payments,
      ) {
    final now = DateTime.now();
    final active = students.where((s) => s.isActive).toList();

    // ---- Stat cards ----
    final totalRooms = rooms.length;
    final occupiedBeds = rooms.fold<int>(0, (sum, r) => sum + r.occupiedBeds);

    int count(PaymentStatus st) =>
        active.where((s) => s.paymentStatus == st).length;
    final paidN = count(PaymentStatus.paid);
    final pendingN = count(PaymentStatus.pending);
    final dueN = count(PaymentStatus.due);

    final pendingPayments = pendingN + dueN;

    final monthlyRevenue = payments
        .where((p) => p.paidAt.year == now.year && p.paidAt.month == now.month)
        .fold<double>(0, (sum, p) => sum + p.amount);


    final income = <IncomePoint>[];
    for (var i = chartMonths - 1; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final total = payments
          .where((p) => p.paidAt.year == m.year && p.paidAt.month == m.month)
          .fold<double>(0, (sum, p) => sum + p.amount);
      income.add(IncomePoint(monthShort(m), total));
    }

    final total = active.length;
    double paidP = 0, pendingP = 0, dueP = 0;
    if (total > 0) {
      paidP = (paidN * 100 / total).roundToDouble();
      pendingP = (pendingN * 100 / total).roundToDouble();
      dueP = (100 - paidP - pendingP).clamp(0, 100).toDouble();
    }

    final recent = active
        .take(recentCount)
        .map((s) => StudentPaymentItem(
      id: s.id,
      name: s.name,
      photoUrl: s.photoUrl,
      status: s.paymentStatus.label,
    ))
        .toList();

    return DashboardStats(
      totalRooms: totalRooms,
      occupiedBeds: occupiedBeds,
      pendingPayments: pendingPayments,
      monthlyRevenue: monthlyRevenue,
      income: income,
      breakdown: PaymentBreakdown(paid: paidP, pending: pendingP, due: dueP),
      recentStudents: recent,
    );
  }
}