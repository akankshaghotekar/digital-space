class ProjectModel {
  final String srNo;
  final String projectName;

  ProjectModel({required this.srNo, required this.projectName});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      srNo: json['srno'] ?? '',
      projectName: json['project_name'] ?? '',
    );
  }
}
