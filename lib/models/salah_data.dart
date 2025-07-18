// models/salah_data.dart
class SalahData {
  final String date;
  final Map<String, bool> prayers;
  final int completedCount;

  SalahData({
    required this.date,
    required this.prayers,
    required this.completedCount,
  });

  factory SalahData.fromJson(Map<String, dynamic> json) {
    return SalahData(
      date: json['date'] as String,
      prayers: Map<String, bool>.from(json['prayers']),
      completedCount: json['completedCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prayers': prayers,
      'completedCount': completedCount,
    };
  }
}