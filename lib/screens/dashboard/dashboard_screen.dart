import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/progress/progress_status_model.dart';
import 'package:digital_space/model/project_model/project_model.dart';
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
  Future<List<ProjectModel>>? _activeProjectsFuture;
  Future<ProgressStatusModel?>? _progressFuture;

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
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _urgentTaskFuture = _loadUrgentTasks();
    _activeProjectsFuture = ApiService.getActiveProjects();
    _progressFuture = _loadProgress();
  }

  Future<ProgressStatusModel?> _loadProgress() async {
    final userSrNo = await SharedPrefHelper.getUserSrNo();
    if (userSrNo == null) return null;

    return ApiService.getProgressStatus(userSrNo: userSrNo);
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

    final tasks = await ApiService.viewTasks(
      usersrno: usersrno!,
      employeesrno: employeesrno!,
    );

    return tasks
        .where((e) => e.taskPriority.toLowerCase() == "urgent")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.primaryBlue
            : null,
        foregroundColor: Colors.white,
        elevation: Theme.of(context).brightness == Brightness.light ? 2 : 0,
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
                SizedBox(height: 20.h),

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
                            // Text(
                            //   "30/40 task done",
                            //   style: TextStyle(
                            //     fontSize: 13.sp,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 6.h,
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

                          lineWidth: 6.w,
                          progressColor: AppColors.primaryBlue,
                          center: FutureBuilder<ProgressStatusModel?>(
                            future: _progressFuture,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularPercentIndicator(
                                  radius: 40.r,
                                  percent: 0.0,
                                  lineWidth: 6.w,
                                  progressColor: AppColors.primaryBlue,
                                  center: const Text("0%"),
                                );
                              }

                              final progress = snapshot.data!;

                              return CircularPercentIndicator(
                                radius: 40.r,
                                percent: progress.progress.clamp(0.0, 1.0),
                                lineWidth: 6.w,
                                progressColor: AppColors.primaryBlue,
                                center: Text(
                                  progress.progressText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
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
                            deadline: task.date,
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
                  child: FutureBuilder<List<ProjectModel>>(
                    future: _activeProjectsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final projects = snapshot.data ?? [];

                      if (projects.isEmpty) {
                        return Center(
                          child: Text(
                            "No active projects",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: projects.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final project = projects[index];

                          return _activeProjectCard(
                            context,
                            title: project.projectName,
                            progress: 0.6 + (index * 0.05),
                            gradientIndex: index,
                          );
                        },
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
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Urgent badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "URGENT",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),

          SizedBox(height: 10.h),

          /// Title
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          const Spacer(),

          /// Deadline
          Text(
            "Deadline: $deadline",
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
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

    return Container(
      width: 240.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Project title
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          SizedBox(height: 14.h),

          /// Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8.h,
              backgroundColor: isDark ? Colors.white24 : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),

          SizedBox(height: 8.h),

          /// Progress text
          Text(
            "${(progress * 100).toInt()}% completed",
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
