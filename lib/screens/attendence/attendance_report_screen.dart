import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/attendence_model/attendance_report_model.dart';
import 'package:digital_space/screens/attendence/attendance_regularize_form.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime? fromDate = DateTime.now();
  DateTime? toDate = DateTime.now();

  bool showReport = false;
  String? userSrNo;
  bool isLoading = false;

  List<AttendanceReportModel> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    userSrNo = await SharedPrefHelper.getUserSrNo();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate! : toDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        isFrom ? fromDate = picked : toDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "--";
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  String getDay(String date) {
    try {
      return date.split('-')[0];
    } catch (_) {
      return '--';
    }
  }

  String getMonth(String date) {
    try {
      final month = int.parse(date.split('-')[1]);
      const months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ];
      return months[month - 1];
    } catch (_) {
      return '--';
    }
  }

  String getStatus(AttendanceReportModel item) {
    if (item.punchInTime != '--' && item.punchOutTime != '--') {
      return "Present";
    }
    if (item.punchInTime != '--') {
      return "Half Day";
    }
    return "Absent";
  }

  String extractTime(String dateTime) {
    if (dateTime == '--' || dateTime.isEmpty) return '--';
    return dateTime.split(' ').last;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Attendance Report")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              /// 📅 Date Selection Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _dateTile(
                      label: "From",
                      date: _formatDate(fromDate),
                      onTap: () => _pickDate(true),
                      isDark: isDark,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    _dateTile(
                      label: "To",
                      date: _formatDate(toDate),
                      onTap: () => _pickDate(false),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔍 View Button
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  onPressed: () async {
                    if (userSrNo == null) return;

                    setState(() => isLoading = true);

                    attendanceData = await ApiService.getAttendanceReport(
                      userSrNo: userSrNo!,
                      fromDate: _formatDate(fromDate),
                      toDate: _formatDate(toDate),
                    );

                    setState(() {
                      isLoading = false;
                      showReport = true;
                    });
                  },
                  child: Text(
                    "View Report",
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// 📋 Attendance List
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: showReport
                      ? ListView.builder(
                          itemCount: attendanceData.length,
                          itemBuilder: (context, index) {
                            final item = attendanceData[index];
                            return _attendanceTile(item: item, isDark: isDark);
                          },
                        )
                      : Center(
                          child: Text(
                            "Select date range to view report",
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📅 Date Tile
  Widget _dateTile({
    required String label,
    required String date,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : Colors.black,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18.sp,
                color: isDark ? Colors.white70 : Colors.black,
              ),
              SizedBox(width: 6.w),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 📌 Attendance Tile
  Widget _attendanceTile({
    required AttendanceReportModel item,
    required bool isDark,
  }) {
    final status = getStatus(item);
    final bool isRequested = item.attendanceRegularize == "Request";
    final bool isApproved = item.attendanceRegularize == "Approved";

    Color statusColor = status == "Present"
        ? Colors.green
        : status == "Half Day"
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Date Box
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getDay(item.date),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  getMonth(item.date),
                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          /// Punch Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _timeRow("Punch In", extractTime(item.punchInTime), isDark),
                SizedBox(height: 6.h),
                _timeRow("Punch Out", extractTime(item.punchOutTime), isDark),
              ],
            ),
          ),

          /// Regularize Action
          GestureDetector(
            onTap: isApproved
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AttendanceRegularizeForm(srno: item.srno),
                      ),
                    );

                    if (result == true) {
                      setState(() => showReport = false);
                      attendanceData = await ApiService.getAttendanceReport(
                        userSrNo: userSrNo!,
                        fromDate: _formatDate(fromDate),
                        toDate: _formatDate(toDate),
                      );
                      setState(() => showReport = true);
                    }
                  },
            child: Column(
              children: [
                Icon(
                  Icons.edit_calendar,
                  size: 26.sp,
                  color: isApproved
                      ? Colors.green
                      : isRequested
                      ? Colors.orange
                      : AppColors.primaryBlue,
                ),
                SizedBox(height: 4.h),
                Text(
                  isApproved
                      ? "Approved"
                      : isRequested
                      ? "Request Sent"
                      : "Not Requested",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isApproved
                        ? Colors.green
                        : isRequested
                        ? Colors.orange
                        : isDark
                        ? Colors.white54
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeRow(String label, String value, bool isDark) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 13.sp,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
