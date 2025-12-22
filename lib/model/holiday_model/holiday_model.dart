class HolidayModel {
  final String srNo;
  final String date;
  final String type;
  final String title;

  HolidayModel({
    required this.srNo,
    required this.date,
    required this.type,
    required this.title,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      srNo: json['srno'] ?? '',
      date: json['date'] ?? '',
      type: json['holiday_type'] ?? '',
      title: (json['holiday_title'] ?? '').replaceAll('\n', ' '),
    );
  }
}
