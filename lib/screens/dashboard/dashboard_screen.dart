import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/task_model/task_model.dart';
import 'package:digital_space/screens/task/task_screen.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:digital_space/utils/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = "";
  Future<List<TaskModel>>? _urgentTaskFuture;
  final String todayDate = DateFormat('dd MMM').format(DateTime.now());

  final List<List<Color>> activeProjectGradientsLight = [
    [const Color(0xFFB1CFFF), const Color(0xFF729CFD)],
    [const Color(0xFFAEFCD3), const Color(0xFF60FF9D)],
    [const Color(0xFFFFE6BE), const Color(0xFFFFCC7F)],
    [
      const Color.fromARGB(255, 222, 192, 255),
      const Color.fromARGB(255, 172, 117, 255),
    ],
  ];

  final List<List<Color>> activeProjectGradientsDark = [
    [const Color(0xFF1E3A8A), const Color(0xFF312E81)],
    [const Color(0xFF064E3B), const Color(0xFF065F46)],
    [const Color(0xFF7C2D12), const Color(0xFF9A3412)],
    [const Color(0xFF4C1D95), const Color(0xFF5B21B6)],
  ];
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _urgentTaskFuture = _loadUrgentTasks();
  }

  Future<void> _loadUserName() async {
    final name = await SharedPrefHelper.getUserName();
    if (!mounted) return;

    setState(() {
      _userName = name ?? "User";
    });
  }

  Future<List<TaskModel>> _loadUrgentTasks() async {
    final usersrno = await SharedPrefHelper.getUserSrNo();
    final employeesrno = await SharedPrefHelper.getEmployeeSrNo();

    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    final tasks = await ApiService.viewTasks(
      usersrno: usersrno!,
      employeesrno: employeesrno!,
      fromDate: today,
      toDate: today,
    );

    // Only urgent tasks
    return tasks.where((e) => e.taskPriority == "IU").toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode),
            onPressed: ThemeController.toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Text(
                  "Hi, $_userName\nBe productive today",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20.h),

                /// Search
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 12.w),
                //   decoration: BoxDecoration(
                //     color: isDark ? AppColors.darkCard : AppColors.lightCard,
                //     borderRadius: BorderRadius.circular(12.r),
                //   ),
                //   child: TextField(
                //     decoration: const InputDecoration(
                //       border: InputBorder.none,
                //       hintText: "Search task",
                //       icon: Icon(Icons.search),
                //     ),
                //   ),
                // ),
                SizedBox(height: 20.h),

                /// Task Progress
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskScreen()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Task Progress",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "30/40 task done",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                todayDate,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        CircularPercentIndicator(
                          radius: 40.r,
                          percent: 0.8,
                          lineWidth: 6.w,
                          progressColor: AppColors.primaryBlue,
                          center: Text(
                            "80%",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                ///  Urgent Tasks
                Text(
                  "Urgent Tasks",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12.h),

                SizedBox(
                  height: 120.h,
                  child: FutureBuilder<List<TaskModel>>(
                    future: _urgentTaskFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final tasks = snapshot.data ?? [];

                      if (tasks.isEmpty) {
                        return Center(
                          child: Text(
                            "No urgent tasks",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: tasks.length > 5 ? 5 : tasks.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _urgentTaskCard(
                            context,
                            title: task.taskName,
                            deadline: task.date ?? "Today",
                          );
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 28.h),

                /// Active Projects
                Text(
                  "Active Projects",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12.h),

                SizedBox(
                  height: 150.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (context, index) {
                      return _activeProjectCard(
                        context,
                        title: "Face Recognition App ${index + 1}",
                        progress: 0.65 - (index * 0.1),
                        gradientIndex: index,
                      );
                    },
                  ),
                ),

                // /// Cards
                // Expanded(
                //   child: GridView.count(
                //     crossAxisCount: 2,
                //     crossAxisSpacing: 12.w,
                //     mainAxisSpacing: 12.h,
                //     children: [
                //       _taskCard(context, "UX Design", AppColors.purple, "70%"),
                //       _taskCard(
                //         context,
                //         "API Integration",
                //         AppColors.blue,
                //         "40%",
                //       ),
                //       _taskCard(
                //         context,
                //         "Face Recognition",
                //         AppColors.green,
                //         "60%",
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _taskCard(
  //   BuildContext context,
  //   String title,
  //   Color color,
  //   String progress,
  // ) {
  //   return Container(
  //     padding: EdgeInsets.all(14.w),
  //     decoration: BoxDecoration(
  //       color: color,
  //       borderRadius: BorderRadius.circular(16.r),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           title,
  //           style: TextStyle(
  //             fontSize: 16.sp,
  //             color: Colors.white,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const Spacer(),
  //         Text(
  //           "Progress $progress",
  //           style: const TextStyle(color: Colors.white),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _urgentTaskCard(
    BuildContext context, {
    required String title,
    required String deadline,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 220.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3A1C1C), const Color(0xFF5C2323)]
              : [const Color(0xFFFFADAD), const Color(0xFFFF5757)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Text(
              "URGENT",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            "Deadline: $deadline",
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeProjectCard(
    BuildContext context, {
    required String title,
    required double progress,
    required int gradientIndex,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? activeProjectGradientsDark[gradientIndex %
              activeProjectGradientsDark.length]
        : activeProjectGradientsLight[gradientIndex %
              activeProjectGradientsLight.length];

    return Container(
      width: 240.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Project Title
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          SizedBox(height: 14.h),

          /// Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: isDark ? Colors.white24 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.lightBlueAccent : AppColors.primaryBlue,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          /// Progress Text
          Text(
            "${(progress * 100).toInt()}% completed",
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
