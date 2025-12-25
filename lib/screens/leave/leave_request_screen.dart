import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String halfDay = "No";
  final TextEditingController reasonController = TextEditingController();
  String? userSrNo;

  int availableBalance = 0;
  int lwp = 0;
  double leaveAppliedFor = 0;

  bool get _isValid =>
      fromDate != null &&
      toDate != null &&
      !toDate!.isBefore(fromDate!) &&
      reasonController.text.trim().isNotEmpty;

  String _formatLeaveApplied(double val) {
    if (val <= 0) return "--";
    if (val == val.roundToDouble()) {
      return "${val.toInt()} ${val > 1 ? 'days' : 'day'}";
    }
    return "${val.toStringAsFixed(1)} days";
  }

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    fromDate = today;
    toDate = today;
    _loadUser();
  }

  Future<void> _loadLeaveBalance() async {
    if (userSrNo == null) return;

    final res = await ApiService.getLeaveBalance(userSrNo!);
    if (res != null) {
      setState(() {
        availableBalance = res.balance;
      });
    }
  }

  Future<void> _loadUser() async {
    userSrNo = await SharedPrefHelper.getUserSrNo();
    await _loadLeaveBalance();
    await _calculateLeave();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (fromDate ?? DateTime.now())
          : (toDate ?? fromDate ?? DateTime.now()),
      firstDate: isFrom ? DateTime(2000) : (fromDate ?? DateTime(2000)),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;

          // Auto-fix To Date
          if (toDate == null || toDate!.isBefore(fromDate!)) {
            toDate = fromDate;
          }
        } else {
          toDate = picked;
        }
      });

      await _calculateLeave();
    }
  }

  Future<void> _calculateLeave() async {
    if (fromDate == null || toDate == null || userSrNo == null) return;

    if (toDate!.isBefore(fromDate!)) return;

    final res = await ApiService.calculateLeave(
      fromDate: _format(fromDate!),
      toDate: _format(toDate!),
      userSrNo: userSrNo!,
      halfDay: halfDay,
    );

    if (res != null) {
      setState(() {
        leaveAppliedFor = res.leaveAppliedFor;
        lwp = res.lwp.toInt();
        availableBalance = res.balance;
      });
    }
  }

  String _format(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.year}";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Apply Leave"),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.primaryBlue
            : null,
        foregroundColor: Colors.white,
        elevation: Theme.of(context).brightness == Brightness.light ? 2 : 0,
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuildDatePickerCard(
                label: "From Date",
                selectedDate: fromDate,
                onTap: () => _pickDate(true),
              ),
              SizedBox(height: 10.h),
              BuildDatePickerCard(
                label: "To Date",
                selectedDate: toDate,
                onTap: () => _pickDate(false),
              ),

              SizedBox(height: 20.h),

              _label("Available Balance", isDark),
              _readonlyBox(availableBalance.toString(), isDark),

              SizedBox(height: 14.h),

              _label("Half Day Leave", isDark),
              _dropdown(isDark),

              SizedBox(height: 14.h),

              _label("Leave Applied For", isDark),
              _readonlyBox(_formatLeaveApplied(leaveAppliedFor), isDark),

              SizedBox(height: 14.h),

              _label("LWP", isDark),
              _readonlyBox(lwp.toString(), isDark),

              SizedBox(height: 20.h),

              _label("Reason", isDark),
              _reasonField(isDark),

              SizedBox(height: 30.h),

              AnimatedOpacity(
                opacity: _isValid ? 1 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    onPressed: _isValid
                        ? () async {
                            if (userSrNo == null) return;

                            final res = await ApiService.applyLeave(
                              fromDate: _format(fromDate!),
                              toDate: _format(toDate!),
                              userSrNo: userSrNo!,
                              halfDay: halfDay,
                              reason: reasonController.text.trim(),
                              lwp: lwp.toString(),
                              balance: availableBalance.toString(),
                            );

                            if (res['status'] == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Leave applied successfully"),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
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

  /// ---------- UI HELPERS (DARK MODE SAFE) ----------

  Widget _label(String text, bool isDark) => Text(
    text,
    style: TextStyle(
      fontSize: 14.sp,
      color: isDark ? Colors.white70 : Colors.black,
    ),
  );

  Widget _readonlyBox(String value, bool isDark) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: AppColors.primaryBlue),
    ),
    child: Text(
      value,
      style: TextStyle(
        fontSize: 14.sp,
        color: isDark ? Colors.white : Colors.black,
      ),
    ),
  );

  Widget _dropdown(bool isDark) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: AppColors.primaryBlue),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: halfDay,
        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        items: [
          "Yes",
          "No",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) async {
          if (val == null) return;
          setState(() => halfDay = val);
          await _calculateLeave();
        },
      ),
    ),
  );

  Widget _reasonField(bool isDark) => Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.transparent,
      border: Border.all(color: AppColors.primaryBlue),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: TextField(
      controller: reasonController,
      maxLines: 3,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: "Enter reason...",
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(12),
      ),
    ),
  );
}
