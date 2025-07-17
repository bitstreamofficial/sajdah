// models/prayer_time.dart
class PrayerTime {
  final String name;
  final DateTime time;
  final bool isCompleted;

  PrayerTime({
    required this.name,
    required this.time,
    this.isCompleted = false,
  });

  PrayerTime copyWith({
    String? name,
    DateTime? time,
    bool? isCompleted,
  }) {
    return PrayerTime(
      name: name ?? this.name,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class SalahData {
  final String date;
  final Map<String, bool> prayers;
  final int completedCount;

  SalahData({
    required this.date,
    required this.prayers,
    required this.completedCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'prayers': prayers,
      'completedCount': completedCount,
    };
  }

  factory SalahData.fromJson(Map<String, dynamic> json) {
    return SalahData(
      date: json['date'],
      prayers: Map<String, bool>.from(json['prayers']),
      completedCount: json['completedCount'],
    );
  }
}