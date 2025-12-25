class ProgressStatusModel {
  final double progress; // 0.0 – 1.0
  final String progressText; // "70.60 %"

  ProgressStatusModel({required this.progress, required this.progressText});

  factory ProgressStatusModel.fromJson(Map<String, dynamic> json) {
    final raw = json['progress_status'] ?? "0 %";

    // Extract number from "70.60 %"
    final value =
        double.tryParse(raw.toString().replaceAll('%', '').trim()) ?? 0;

    return ProgressStatusModel(
      progress: value / 100, // convert to 0–1 for indicator
      progressText: raw,
    );
  }
}
