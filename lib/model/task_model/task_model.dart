class TaskModel {
  final String srNo;
  final String date;
  final String taskName;
  final String taskDetail;
  final String taskPriority;
  final String assignedFrom;
  String status;

  TaskModel({
    required this.srNo,
    required this.date,
    required this.taskName,
    required this.taskDetail,
    required this.taskPriority,
    required this.assignedFrom,
    required this.status,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      srNo: json['srno'] ?? '',
      date: json['date'] ?? '',
      taskName: json['task_name'] ?? '',
      taskDetail: json['task_detail'] ?? '',
      taskPriority: json['task_priority'] ?? '',
      assignedFrom: json['assigned_from'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
