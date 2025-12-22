import 'package:digital_space/screens/active_project/active_project_screen.dart';
import 'package:digital_space/screens/attendence/attendance_screen.dart';
import 'package:digital_space/screens/dashboard/dashboard_screen.dart';
import 'package:digital_space/screens/dsi/add_dsi_screen.dart';
import 'package:digital_space/screens/dsi/dsi_screen.dart';
import 'package:digital_space/screens/holiday/holiday_list_screen.dart';
import 'package:digital_space/screens/leave/leave_request_screen.dart';
import 'package:digital_space/screens/leave/leave_view_screen.dart';
import 'package:digital_space/screens/login/login_screen.dart';
import 'package:digital_space/screens/service_ticket/service_ticket_screen.dart';
import 'package:digital_space/screens/task/task_screen.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      child: SafeArea(
        child: Column(
          children: [
            /// App Header / Logo
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 48.sp,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Digital Space",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Divider(),

            /// Menu Items
            Expanded(
              child: ListView(
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: "Home",
                    page: const DashboardScreen(),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.task_alt,
                    title: "Task",
                    page: const TaskScreen(),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.support_agent,
                    title: "Service Ticket",
                    page: const ServiceTicketScreen(),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.folder_open,
                    title: "Active Project",
                    page: const ActiveProjectScreen(),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.fingerprint,
                    title: "Attendance",
                    page: const AttendanceScreen(),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.time_to_leave,
                    title: "Leave",
                    page: const LeaveViewScreen(),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.event,
                    title: "Holiday",
                    page: const HolidayListScreen(),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.insert_chart_outlined,
                    title: "DSI",
                    page: DsiScreen(),
                  ),
                ],
              ),
            ),

            Divider(),

            /// Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                "Logout",
                style: TextStyle(color: Colors.red, fontSize: 15.sp),
              ),
              onTap: () async {
                await SharedPrefHelper.logout();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
            ),

            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  /// Drawer Item Widget
  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => page),
          (route) => route.isFirst,
        );
      },
    );
  }
}
