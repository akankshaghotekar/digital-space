class AttendanceStatusModel {
  final String punchStatus;
  final String punchInTime;
  final String punchOutTime;

  AttendanceStatusModel({
    required this.punchStatus,
    required this.punchInTime,
    required this.punchOutTime,
  });

  factory AttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusModel(
      punchStatus: json['punch_status'] ?? '',
      punchInTime: json['punch_in_time'] ?? '',
      punchOutTime: json['punch_out_time'] ?? '',
    );
  }
}
