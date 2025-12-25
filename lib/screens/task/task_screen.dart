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

  DateTime? _fromDate;
  DateTime? _toDate;

  bool _isDateFilterApplied = false;

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

  Future<void> _markTaskSeenIfNew(TaskModel task) async {
    final status = task.status.trim().toLowerCase();

    if (status != "new task") return;

    final success = await ApiService.updateTaskStatus(
      srNo: task.srNo,
      status: "Pending",
    );

    if (success) {
      setState(() {
        task.status = "Pending";
      });
    }
  }

  Future<List<TaskModel>> _loadTasks() async {
    final loggedUserSrNo = await SharedPrefHelper.getUserSrNo();
    final loggedEmployeeSrNo = await SharedPrefHelper.getEmployeeSrNo();

    final usersrno = (_isAdmin && _selectedUserSrNo != null)
        ? _selectedUserSrNo!
        : loggedUserSrNo!;

    final employeesrno = (_isAdmin && _selectedEmployeeSrNo != null)
        ? _selectedEmployeeSrNo!
        : loggedEmployeeSrNo!;

    List<TaskModel> tasks;

    if (!_isDateFilterApplied) {
      ///  Call API WITHOUT date
      tasks = await ApiService.viewTasks(
        usersrno: usersrno,
        employeesrno: employeesrno,
      );
    } else {
      ///  Call API WITH date
      tasks = await ApiService.viewTasks(
        usersrno: usersrno,
        employeesrno: employeesrno,
        fromDate: DateFormat('dd-MM-yyyy').format(_fromDate!),
        toDate: DateFormat('dd-MM-yyyy').format(_toDate!),
      );
    }

    // --- ADD SORTING HERE ---
    tasks.sort((a, b) {
      try {
        final da = DateFormat('dd-MM-yyyy').parse(a.date);
        final db = DateFormat('dd-MM-yyyy').parse(b.date);
        return db.compareTo(da);
      } catch (e) {
        return 0;
      }
    });

    return tasks;
  }

  Future<void> _updateTaskStatus(TaskModel task, bool completed) async {
    final newStatus = completed ? "Complete" : "Pending";

    final success = await ApiService.updateTaskStatus(
      srNo: task.srNo,
      status: newStatus,
    );

    if (success) {
      setState(() {
        task.status = newStatus;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update task status")),
      );
    }
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked;
        _toDate ??= picked;
        _isDateFilterApplied = true;
        _taskFuture = _loadTasks();
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? (_fromDate ?? DateTime.now()),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _toDate = picked;
        _isDateFilterApplied = true;
        _taskFuture = _loadTasks();
      });
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
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.primaryBlue
            : null,
        elevation: Theme.of(context).brightness == Brightness.light ? 2 : 0,
        foregroundColor: Colors.white,
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

                // allTasks.sort((a, b) {
                //   final da = DateFormat('dd-MM-yyyy').parse(a.date);
                //   final db = DateFormat('dd-MM-yyyy').parse(b.date);
                //   return db.compareTo(da);
                // });

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
    final isExpanded = _expandedTaskSrNo == task.srNo;
    final isUrgent = task.taskPriority.toLowerCase() == "urgent";
    final isComplete = task.status.toLowerCase() == "complete";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () async {
        final willExpand = !isExpanded;

        setState(() {
          _expandedTaskSrNo = willExpand ? task.srNo : null;
        });

        if (willExpand) {
          await _markTaskSeenIfNew(task);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + Assigned
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Assigned to ${task.assignedFrom}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Priority Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? (isDark
                              ? Colors.red.withOpacity(0.2)
                              : Colors.red.shade50)
                        : (isDark
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.orange.shade50),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    task.taskPriority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isUrgent ? Colors.redAccent : Colors.orangeAccent,
                    ),
                  ),
                ),

                SizedBox(width: 6.w),

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ],
            ),

            /// EXPANDED CONTENT
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: EdgeInsets.only(top: 14.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow("Description", task.taskDetail),
                          SizedBox(height: 6.h),
                          _detailRow("Date", task.date),
                          SizedBox(height: 6.h),

                          /// Status Chip
                          Row(
                            children: [
                              Text(
                                "Status:",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isComplete
                                      ? (isDark
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.green.shade50)
                                      : (isDark
                                            ? Colors.blue.withOpacity(0.2)
                                            : Colors.blue.shade50),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  task.status.replaceAll("\n", " "),
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isComplete
                                        ? Colors.greenAccent
                                        : Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),
                          Divider(
                            color: isDark
                                ? Colors.white12
                                : Colors.grey.shade300,
                          ),
                          SizedBox(height: 6.h),

                          /// Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Mark as Completed",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Switch(
                                value: isComplete,
                                activeColor: Colors.green,
                                onChanged: (val) async {
                                  await _updateTaskStatus(task, val);
                                },
                              ),
                            ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            "$label:",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateCard(
    String label,
    DateTime? date,
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
              date == null
                  ? "Select date"
                  : DateFormat('dd MMM yyyy').format(date),
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
