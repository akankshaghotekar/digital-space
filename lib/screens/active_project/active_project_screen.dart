import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActiveProjectScreen extends StatelessWidget {
  const ActiveProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: const Text("Active Projects"),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///  Overall Progress Card
              _overallProgressCard(isDark),

              SizedBox(height: 24.h),

              ///  Section title
              Text(
                "Ongoing Projects",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 12.h),

              /// Project list
              Expanded(
                child: ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, __) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    return _projectCard(
                      context,
                      index: index,
                      title: "Project ${index + 1}",
                      progress: 0.25 + (index * 0.2),
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

    final gradientsLight = [
      [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
      [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
      [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
      [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
    ];

    final gradientsDark = [
      [const Color(0xFF1E3A8A), const Color(0xFF312E81)],
      [const Color(0xFF064E3B), const Color(0xFF065F46)],
      [const Color(0xFF7C2D12), const Color(0xFF9A3412)],
      [const Color(0xFF4C1D95), const Color(0xFF5B21B6)],
    ];

    final colors = isDark
        ? gradientsDark[index % gradientsDark.length]
        : gradientsLight[index % gradientsLight.length];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.25),
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
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),

          SizedBox(height: 10.h),

          /// Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              "IN PROGRESS",
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
              backgroundColor: isDark ? Colors.white24 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.lightBlueAccent : AppColors.primaryBlue,
              ),
            ),
          ),

          SizedBox(height: 8.h),

          /// Progress text
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
