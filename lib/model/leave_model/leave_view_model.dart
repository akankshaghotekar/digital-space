class LeaveViewModel {
  final String fromDate;
  final String toDate;
  final String status;

  LeaveViewModel({
    required this.fromDate,
    required this.toDate,
    required this.status,
  });

  factory LeaveViewModel.fromJson(Map<String, dynamic> json) {
    return LeaveViewModel(
      fromDate: json['leave_from_date'] ?? '',
      toDate: json['leave_to_date'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
