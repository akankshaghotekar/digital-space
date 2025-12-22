class ServiceTicketModel {
  final String id;
  final String date;
  final String clientName;
  final String projectName;
  final String issueTitle;
  final String issueDetail;
  final String priority;
  final String status;

  ServiceTicketModel({
    required this.id,
    required this.date,
    required this.clientName,
    required this.projectName,
    required this.issueTitle,
    required this.issueDetail,
    required this.priority,
    required this.status,
  });

  factory ServiceTicketModel.fromJson(Map<String, dynamic> json) {
    return ServiceTicketModel(
      id: json['srno'] ?? '',
      date: json['date'] ?? '',
      clientName: json['client_name'] ?? '',
      projectName: json['project_name'] ?? '',
      issueTitle: json['issue_title'] ?? '',
      issueDetail: json['issue_detail'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
