import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/project_model/project_model.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActiveProjectScreen extends StatefulWidget {
  const ActiveProjectScreen({super.key});

  @override
  State<ActiveProjectScreen> createState() => _ActiveProjectScreenState();
}

class _ActiveProjectScreenState extends State<ActiveProjectScreen> {
  Future<List<ProjectModel>>? _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = ApiService.getActiveProjects();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Active Projects"),
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.primaryBlue
            : null,
        foregroundColor: Colors.white,
        elevation: Theme.of(context).brightness == Brightness.light ? 2 : 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///  Overall Progress Card
              // _overallProgressCard(isDark),

              // SizedBox(height: 24.h),

              ///  Section title
              Text(
                "Ongoing Projects",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 12.h),

              /// Project list
              Expanded(
                child: FutureBuilder<List<ProjectModel>>(
                  future: _projectFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final projects = snapshot.data ?? [];

                    if (projects.isEmpty) {
                      return const Center(child: Text("No active projects"));
                    }

                    return ListView.separated(
                      itemCount: projects.length,
                      separatorBuilder: (_, __) => SizedBox(height: 14.h),
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return _projectCard(
                          context,
                          index: index,
                          title: project.projectName,
                          progress: 0.4 + (index * 0.1), // dummy progress
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///  Overall progress summary
  Widget _overallProgressCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A8A), const Color(0xFF312E81)]
              : [const Color(0xFFBBDEFB), const Color(0xFF90CAF9)],
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Overall Progress",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "All active projects",
                style: TextStyle(fontSize: 13.sp, color: Colors.black),
              ),
            ],
          ),
          Text(
            "62%",
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  ///  Individual project card
  Widget _projectCard(
    BuildContext context, {
    required int index,
    required String title,
    required double progress,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
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
          /// Project name
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

          SizedBox(height: 10.h),

          /// Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "IN PROGRESS",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
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
