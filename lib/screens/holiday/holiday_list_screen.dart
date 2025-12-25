import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/model/holiday_model/holiday_model.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HolidayListScreen extends StatefulWidget {
  const HolidayListScreen({super.key});

  @override
  State<HolidayListScreen> createState() => _HolidayListScreenState();
}

class _HolidayListScreenState extends State<HolidayListScreen> {
  late Future<List<HolidayModel>> _holidayFuture;

  @override
  void initState() {
    super.initState();
    _holidayFuture = ApiService.getHolidayList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Holiday List"),
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.primaryBlue
            : null,
        foregroundColor: Colors.white,
        elevation: Theme.of(context).brightness == Brightness.light ? 2 : 0,
      ),

      body: FutureBuilder<List<HolidayModel>>(
        future: _holidayFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final holidays = snapshot.data ?? [];

          if (holidays.isEmpty) {
            return const Center(child: Text("No holidays found"));
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: holidays.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return _holidayCard(holidays[index], isDark);
            },
          );
        },
      ),
    );
  }

  Widget _holidayCard(HolidayModel holiday, bool isDark) {
    final date = DateFormat('dd-MMM-yyyy').parse(holiday.date);
    final day = DateFormat('dd').format(date);
    final month = DateFormat('MMM').format(date);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Date Box
          Container(
            width: 60.w,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.redAccent.withOpacity(0.2)
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(fontSize: 12.sp, color: Colors.redAccent),
                ),
              ],
            ),
          ),

          SizedBox(width: 14.w),

          /// Holiday Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  holiday.type,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.greenAccent : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
