import 'dart:math' as math;
import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/screens/attendence/attendance_report_screen.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/animation/animated_page_route.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/common/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  bool isPunchedIn = false;
  bool isDayCompleted = false;

  bool _isPunching = false;

  String? userSrNo;
  String? employeeSrNo;

  String? punchInTime;
  String? punchOutTime;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _ensureLocationAccess();
    _loadUser();
  }

  Future<void> _loadUser() async {
    userSrNo = await SharedPrefHelper.getUserSrNo();
    employeeSrNo = await SharedPrefHelper.getEmployeeSrNo();
    _loadAttendanceStatus();
  }

  Future<void> _loadAttendanceStatus() async {
    if (userSrNo == null) return;

    final res = await ApiService.getAttendanceStatus(userSrNo!);
    if (res != null) {
      setState(() {
        isPunchedIn = res.punchStatus == "Punch Out";
        isDayCompleted = res.punchOutTime.isNotEmpty;
        punchInTime = res.punchInTime.isEmpty ? null : res.punchInTime;
        punchOutTime = res.punchOutTime.isEmpty ? null : res.punchOutTime;
      });
    }
  }

  Future<void> _ensureLocationAccess() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
            "Please enable location permission from app settings to mark attendance.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
      return;
    }

    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Enable Location"),
          content: const Text(
            "Please turn on location services (GPS) to mark attendance.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
              child: const Text("Turn On"),
            ),
          ],
        ),
      );
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  String _formattedDateForApi() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handlePunch() async {
    if (userSrNo == null || employeeSrNo == null || _isPunching) return;

    setState(() {
      _isPunching = true;
    });

    _pulseController.repeat(); //  START ROTATION

    try {
      final position = await _getCurrentLocation();

      if (position == null) {
        _pulseController.stop();
        setState(() => _isPunching = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to get current location. Please try again."),
          ),
        );
        return;
      }

      final inOut = isPunchedIn ? "OUT" : "IN";

      final success = await ApiService.markAttendance(
        userSrNo: userSrNo!,
        employeeSrNo: employeeSrNo!,
        billDate: _formattedDateForApi(),
        inOut: inOut,
        lat: position.latitude.toString(),
        lng: position.longitude.toString(),
      );

      if (success) {
        await _loadAttendanceStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to mark attendance")),
        );
      }
    } finally {
      _pulseController.stop(); //  STOP ROTATION
      setState(() {
        _isPunching = false;
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
        title: const Text("Attendance"),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              ///  Animated Punch Button
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isDayCompleted
                    ? _completedView()
                    : _punchButton(
                        isDark: isDark,
                        label: isPunchedIn ? "PUNCH OUT" : "PUNCH IN",
                        color: isPunchedIn ? Colors.green : Colors.red,
                        onTap: _handlePunch,
                      ),
              ),

              SizedBox(height: 40.h),

              ///  Punch Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _timeInfo(
                    label: "Punch In",
                    time: punchInTime ?? "--:--",
                    color: Colors.red,
                  ),
                  _timeInfo(
                    label: "Punch Out",
                    time: punchOutTime ?? "--:--",
                    color: Colors.green,
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              const Spacer(),

              /// Report Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      AnimatedPageRoute(page: AttendanceReportScreen()),
                    );
                  },
                  icon: const Icon(Icons.bar_chart, color: Colors.white),
                  label: const Text(
                    "View Attendance Report",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  ///  Punch Button with animation
  Widget _punchButton({
    required bool isDark,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final double size = 220.w;

    return GestureDetector(
      onTap: _isPunching ? null : onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              if (!_pulseController.isAnimating) {
                return const SizedBox();
              }

              return Transform.rotate(
                angle: _pulseController.value * 2 * math.pi,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.6),
                        color.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint, size: 46.sp, color: color),
                SizedBox(height: 10.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///  Completed View
  Widget _completedView() {
    return Column(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 80.sp),
        SizedBox(height: 12.h),
        Text(
          "Attendance Marked for Today",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  ///  Time Info
  Widget _timeInfo({
    required String label,
    required String time,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(Icons.access_time, color: color, size: 26.sp),
        SizedBox(height: 6.h),
        Text(
          time,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
