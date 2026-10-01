class IncomePoint {
  final String label;
  final double value;
  const IncomePoint(this.label, this.value);
}

class PaymentBreakdown {
  final double paid;
  final double pending;
  final double due;
  const PaymentBreakdown({this.paid = 0, this.pending = 0, this.due = 0});

  double get total => paid + pending + due;
  int get paidPercent => total == 0 ? 0 : (paid / total * 100).round();
}

class StudentPaymentItem {
  final String id;
  final String name;
  final String? photoUrl;
  final String status; // Paid, Pending, Due

  const StudentPaymentItem({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.status,
  });
}

class DashboardStats {
  final int totalRooms;
  final int occupiedBeds;
  final int pendingPayments;
  final double monthlyRevenue;
  final List<IncomePoint> income;
  final PaymentBreakdown breakdown;
  final List<StudentPaymentItem> recentStudents;

  const DashboardStats({
    required this.totalRooms,
    required this.occupiedBeds,
    required this.pendingPayments,
    required this.monthlyRevenue,
    required this.income,
    required this.breakdown,
    required this.recentStudents,
  });

  factory DashboardStats.demo() => const DashboardStats(
    totalRooms: 120,
    occupiedBeds: 85,
    pendingPayments: 178,
    monthlyRevenue: 17860,
    income: [
      IncomePoint('10am', 5500),
      IncomePoint('11am', 3900),
      IncomePoint('12am', 4800),
      IncomePoint('01am', 3000),
      IncomePoint('02am', 5600),
    ],
    breakdown: PaymentBreakdown(paid: 80, pending: 12, due: 8),
    recentStudents: [
      StudentPaymentItem(id: '1', name: 'Sameer Khan', status: 'Paid'),
      StudentPaymentItem(id: '2', name: 'Ali Raza', status: 'Due'),
      StudentPaymentItem(id: '3', name: 'Hamza Ahmed', status: 'Pending'),
      StudentPaymentItem(id: '4', name: 'Usman Tariq', status: 'Due'),
    ],
  );
}