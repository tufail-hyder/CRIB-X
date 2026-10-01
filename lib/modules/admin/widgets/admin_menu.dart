import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

class AdminMenuItem {
  final String title;
  final IconData icon;
  final String route;
  const AdminMenuItem(this.title, this.icon, this.route);
}

const adminMenu = <AdminMenuItem>[
  AdminMenuItem('Dashboard', Icons.grid_view_rounded, AppRoutes.adminDashboard),
  AdminMenuItem('Hostel Profile', Icons.person_rounded, AppRoutes.adminHostelProfile),
  AdminMenuItem('Rooms & Beds', Icons.bed_rounded, AppRoutes.adminRooms),
  AdminMenuItem('Students', Icons.school_rounded, AppRoutes.adminStudents),
  AdminMenuItem('Bookings', Icons.calendar_month_rounded, AppRoutes.adminBookings),
  AdminMenuItem('Payments', Icons.account_balance_wallet_rounded, AppRoutes.adminPayments),
  AdminMenuItem('Complaints', Icons.mark_chat_unread_rounded, AppRoutes.adminComplaints),
  AdminMenuItem('Subscriptions', Icons.workspace_premium_rounded, AppRoutes.adminSubscription),
  AdminMenuItem('Reports', Icons.bar_chart_rounded, AppRoutes.adminReports),
  AdminMenuItem('Setting', Icons.settings_rounded, AppRoutes.adminSettings),
];