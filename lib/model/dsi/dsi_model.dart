class DsiModel {
  final String id;
  final String date;
  final String title;
  final String description;
  final String? image;
  final String? link;
  final String? relatedTo;
  final String status;

  DsiModel({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.image,
    required this.link,
    required this.relatedTo,
    required this.status,
  });

  factory DsiModel.fromJson(Map<String, dynamic> json) {
    return DsiModel(
      id: json['srno'] ?? '',
      date: json['date'] ?? '',
      title: json['dsi_title'] ?? '',
      description: json['dsi_description'] ?? '',
      image: json['img1'],
      link: json['dsi_link'],
      relatedTo: json['dsi_related_to'],
      status: json['status'] ?? '',
    );
  }
}
