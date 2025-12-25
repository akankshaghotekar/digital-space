import 'package:digital_space/model/leave_model/leave_view_model.dart';
import 'package:digital_space/screens/leave/leave_request_screen.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:digital_space/utils/common/date_picker.dart';
import 'package:digital_space/api/api_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LeaveViewScreen extends StatefulWidget {
  const LeaveViewScreen({super.key});

  @override
  State<LeaveViewScreen> createState() => _LeaveViewScreenState();
}

class _LeaveViewScreenState extends State<LeaveViewScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  bool showResult = false;
  bool isLoading = false;

  String? userSrNo;

  int leaveBalance = 0;
  List<LeaveViewModel> leaveList = [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    fromDate = today;
    toDate = today;
    _loadUser();
  }

  Future<void> _loadUser() async {
    userSrNo = await SharedPrefHelper.getUserSrNo();
    _loadBalance();
  }

  /// Load leave balance
  Future<void> _loadBalance() async {
    if (userSrNo == null) return;

    final res = await ApiService.getLeaveBalance(userSrNo!);
    if (res != null) {
      setState(() => leaveBalance = res.balance);
    }
  }

  /// Pick date
  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          toDate ??= picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  /// Format date for API (dd-MM-yyyy)
  String _format(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  /// Fetch leaves
  Future<void> _viewLeaves() async {
    if (userSrNo == null) return;

    setState(() {
      isLoading = true;
      showResult = false;
    });

    final data = await ApiService.viewLeaves(
      fromDate: _format(fromDate!),
      toDate: _format(toDate!),
      userSrNo: userSrNo!,
    );

    setState(() {
      leaveList = data;
      isLoading = false;
      showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Leave View"),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.primaryBlue
            : null,
        foregroundColor: Colors.white,
        elevation: Theme.of(context).brightness == Brightness.light ? 2 : 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaveRequestScreen()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _balanceCard(),
            SizedBox(height: 20.h),

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
            SizedBox(height: 14.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onPressed: _viewLeaves,
                child: Text("View", style: TextStyle(color: Colors.white)),
              ),
            ),

            SizedBox(height: 20.h),

            if (isLoading) const Center(child: CircularProgressIndicator()),

            if (showResult && !isLoading)
              Expanded(
                child: leaveList.isEmpty
                    ? const Center(child: Text("No leave data found"))
                    : ListView.builder(
                        itemCount: leaveList.length,
                        itemBuilder: (_, i) => _leaveCard(leaveList[i]),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  /// Balance Card
  Widget _balanceCard() => Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: AppColors.primaryBlue),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            "$leaveBalance",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 8.w),
        const Text("Available Leaves"),
      ],
    ),
  );

  /// Leave Card
  Widget _leaveCard(LeaveViewModel item) {
    Color color;
    switch (item.status) {
      case "Approved":
        color = Colors.green;
        break;
      case "Rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(child: Text(item.fromDate)),
          Expanded(child: Text(item.toDate, textAlign: TextAlign.center)),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: color),
              ),
              child: Text(
                item.status,
                textAlign: TextAlign.center,
                style: TextStyle(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
