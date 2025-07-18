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

  PrayerTime copyWith({String? name, DateTime? time, bool? isCompleted}) {
    return PrayerTime(
      name: name ?? this.name,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
