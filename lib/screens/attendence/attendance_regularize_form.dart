import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendanceRegularizeForm extends StatefulWidget {
  final String srno;
  const AttendanceRegularizeForm({super.key, required this.srno});

  @override
  State<AttendanceRegularizeForm> createState() =>
      _AttendanceRegularizeFormState();
}

class _AttendanceRegularizeFormState extends State<AttendanceRegularizeForm> {
  final TextEditingController commentController = TextEditingController();
  bool isLoading = false;

  bool get isValid => commentController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!isValid) return;

    setState(() => isLoading = true);

    final res = await ApiService.addAttendanceRegularize(
      srno: widget.srno,
      comments: commentController.text.trim(),
    );

    setState(() => isLoading = false);

    if (res['status'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request submitted successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'] ?? "Failed")));
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Regularize"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Comment", style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 6.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: TextField(
                controller: commentController,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "Enter reason...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid && !isLoading ? _submit : null,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
