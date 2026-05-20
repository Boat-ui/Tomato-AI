class ScanHistory {
  final String imagePath;
  final String disease;
  final String date;

  ScanHistory({
    required this.imagePath,
    required this.disease,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        "imagePath": imagePath,
        "disease": disease,
        "date": date,
      };

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      imagePath: json["imagePath"],
      disease: json["disease"],
      date: json["date"],
    );
  }
}