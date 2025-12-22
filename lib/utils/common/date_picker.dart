import 'package:digital_space/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildDatePickerCard extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;

  const BuildDatePickerCard({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.primaryBlue, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Label
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 6.h),

            /// Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? "-- -- ----"
                      : "${selectedDate!.day.toString().padLeft(2, '0')}-"
                            "${selectedDate!.month.toString().padLeft(2, '0')}-"
                            "${selectedDate!.year}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
