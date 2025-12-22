class AttendanceReportModel {
  final String srno;
  final String date;
  final String punchInTime;
  final String punchOutTime;
  final String? attendanceRegularize;

  AttendanceReportModel({
    required this.srno,
    required this.date,
    required this.punchInTime,
    required this.punchOutTime,
    this.attendanceRegularize,
  });

  factory AttendanceReportModel.fromJson(Map<String, dynamic> json) {
    return AttendanceReportModel(
      srno: json['srno'] ?? '',
      date: json['date'] ?? '',
      punchInTime: json['punch_in_time'] ?? '--',
      punchOutTime: json['punch_out_time'] ?? '--',
      attendanceRegularize: json['attendance_regularize'],
    );
  }
}
