import '../models/dashboard_stats_model.dart';

class DashboardRepository {
  Future<DashboardStats> getStats(String hostelId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return DashboardStats.demo();
  }
}