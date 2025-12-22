import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/task_model/task_model.dart';
import 'package:digital_space/model/user_model/user_model.dart';
import 'package:digital_space/screens/task/add_task_screen.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Future<List<TaskModel>>? _taskFuture;
  String? _expandedTaskSrNo;

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  Future<List<UserModel>>? _usersFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _isAdmin = false;

  String? _selectedUserSrNo;
  String? _selectedEmployeeSrNo;

  @override
  void initState() {
    super.initState();
    _taskFuture = _loadTasks();
    _initUser();
    _usersFuture = ApiService.getUsers();
  }

  Future<void> _initUser() async {
    final userSrNo = await SharedPrefHelper.getUserSrNo();
    if (!mounted) return;

    setState(() {
      _isAdmin = userSrNo == "1";
      if (_isAdmin) {
        _selectedUserSrNo = "0";
        _selectedEmployeeSrNo = "0";
      }
    });
  }

  Future<List<TaskModel>> _loadTasks() async {
    final loggedUserSrNo = await SharedPrefHelper.getUserSrNo();
    final loggedEmployeeSrNo = await SharedPrefHelper.getEmployeeSrNo();

    final from = DateFormat('dd-MM-yyyy').format(_fromDate);
    final to = DateFormat('dd-MM-yyyy').format(_toDate);

    final usersrno = (_isAdmin && _selectedUserSrNo != null)
        ? _selectedUserSrNo!
        : loggedUserSrNo!;
    final employeesrno = (_isAdmin && _selectedEmployeeSrNo != null)
        ? _selectedEmployeeSrNo!
        : loggedEmployeeSrNo!;

    return ApiService.viewTasks(
      usersrno: usersrno,
      employeesrno: employeesrno,
      fromDate: from,
      toDate: to,
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
        _taskFuture = _loadTasks();
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: _fromDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked;
        if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
      });

      _taskFuture = _loadTasks();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()),
              );
              if (added == true) {
                _taskFuture = _loadTasks();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim().toLowerCase());
              },
              decoration: InputDecoration(
                hintText: "Search task...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white54 : null,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// ADMIN FILTER
          if (_isAdmin)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: FutureBuilder<List<UserModel>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final users = snapshot.data!;

                  return DropdownButtonFormField<String>(
                    value: _selectedUserSrNo,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: "0",
                        child: Text("All Users"),
                      ),
                      ...users.map(
                        (u) => DropdownMenuItem(
                          value: u.userSrNo,
                          child: Text(u.name),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUserSrNo = value;
                        _selectedEmployeeSrNo = value;
                      });

                      _taskFuture = _loadTasks();
                      setState(() {});
                    },
                  );
                },
              ),
            ),

          ///  DATE FILTER
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: _dateCard(
                    "From Date",
                    _fromDate,
                    _pickFromDate,
                    isDark,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _dateCard("To Date", _toDate, _pickToDate, isDark),
                ),
              ],
            ),
          ),

          ///  TASK LIST
          Expanded(
            child: FutureBuilder<List<TaskModel>>(
              future: _taskFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTasks = snapshot.data ?? [];

                allTasks.sort((a, b) {
                  final da = DateFormat('dd-MM-yyyy').parse(a.date);
                  final db = DateFormat('dd-MM-yyyy').parse(b.date);
                  return db.compareTo(da);
                });

                final tasks = _searchQuery.isEmpty
                    ? allTasks
                    : allTasks
                          .where(
                            (t) =>
                                t.taskName.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                t.taskDetail.toLowerCase().contains(
                                  _searchQuery,
                                ) ||
                                t.assignedFrom.toLowerCase().contains(
                                  _searchQuery,
                                ),
                          )
                          .toList();

                final urgent = tasks
                    .where((e) => e.taskPriority.toLowerCase() == "urgent")
                    .toList();

                final important = tasks
                    .where((e) => e.taskPriority.toLowerCase() == "important")
                    .toList();

                if (tasks.isEmpty) {
                  return const Center(child: Text("No tasks found"));
                }

                return ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    _section("Urgent", urgent, isDark),
                    SizedBox(height: 24.h),
                    _section("Important", important, isDark),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<TaskModel> tasks, bool isDark) {
    if (tasks.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) => _taskCard(tasks[index]),
        ),
      ],
    );
  }

  Widget _taskCard(TaskModel task) {
    final isUrgent = task.taskPriority.toLowerCase() == "urgent";

    final isExpanded = _expandedTaskSrNo == task.srNo;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        setState(() {
          _expandedTaskSrNo = isExpanded ? null : task.srNo;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUrgent
                ? [const Color(0xFFFF7280), const Color(0xFFEA3030)]
                : [const Color(0xFFFFC774), const Color(0xFFFDAC32)],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER ROW
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 26.r,
                  lineWidth: 4.w,
                  percent: 0.0,
                  progressColor: Colors.white,
                  backgroundColor: Colors.white24,
                  center: Text(
                    "0%",
                    style: TextStyle(color: Colors.white, fontSize: 11.sp),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Assigned by: ${task.assignedFrom}",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),

            /// EXPANDED CONTENT
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: EdgeInsets.only(top: 14.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow("Description", task.taskDetail),
                          SizedBox(height: 6.h),
                          _detailRow("Priority", task.taskPriority),

                          SizedBox(height: 6.h),
                          _detailRow("Date", task.date),
                          SizedBox(height: 6.h),
                          _detailRow(
                            "Status",
                            task.status.replaceAll("\n", " "),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            "$label:",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  Widget _dateCard(
    String label,
    DateTime date,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
