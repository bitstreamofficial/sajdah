import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTime {
  final String name;
  final String startTime;
  final String endTime;
  final String type; // 'fard', 'nafal', 'prohibited'
  final String? arabicName;

  PrayerTime({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.arabicName,
  });
}

class DateInfo {
  final String readable;
  final String timestamp;
  final HijriDate hijri;
  final GregorianDate gregorian;

  DateInfo({
    required this.readable,
    required this.timestamp,
    required this.hijri,
    required this.gregorian,
  });

  factory DateInfo.fromJson(Map<String, dynamic> json) {
    return DateInfo(
      readable: json['readable'],
      timestamp: json['timestamp'],
      hijri: HijriDate.fromJson(json['hijri']),
      gregorian: GregorianDate.fromJson(json['gregorian']),
    );
  }
}

class HijriDate {
  final String date;
  final String day;
  final String year;
  final HijriMonth month;
  final HijriWeekday weekday;
  final List<String> holidays;

  HijriDate({
    required this.date,
    required this.day,
    required this.year,
    required this.month,
    required this.weekday,
    required this.holidays,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'],
      day: json['day'],
      year: json['year'],
      month: HijriMonth.fromJson(json['month']),
      weekday: HijriWeekday.fromJson(json['weekday']),
      holidays: List<String>.from(json['holidays'] ?? []),
    );
  }
}

class HijriMonth {
  final int number;
  final String en;
  final String ar;
  final int days;

  HijriMonth({
    required this.number,
    required this.en,
    required this.ar,
    required this.days,
  });

  factory HijriMonth.fromJson(Map<String, dynamic> json) {
    return HijriMonth(
      number: json['number'],
      en: json['en'],
      ar: json['ar'],
      days: json['days'],
    );
  }
}

class HijriWeekday {
  final String en;
  final String ar;

  HijriWeekday({required this.en, required this.ar});

  factory HijriWeekday.fromJson(Map<String, dynamic> json) {
    return HijriWeekday(
      en: json['en'],
      ar: json['ar'],
    );
  }
}

class GregorianDate {
  final String date;
  final String day;
  final String year;
  final GregorianMonth month;
  final GregorianWeekday weekday;

  GregorianDate({
    required this.date,
    required this.day,
    required this.year,
    required this.month,
    required this.weekday,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'],
      day: json['day'],
      year: json['year'],
      month: GregorianMonth.fromJson(json['month']),
      weekday: GregorianWeekday.fromJson(json['weekday']),
    );
  }
}

class GregorianMonth {
  final int number;
  final String en;

  GregorianMonth({required this.number, required this.en});

  factory GregorianMonth.fromJson(Map<String, dynamic> json) {
    return GregorianMonth(
      number: json['number'],
      en: json['en'],
    );
  }
}

class GregorianWeekday {
  final String en;

  GregorianWeekday({required this.en});

  factory GregorianWeekday.fromJson(Map<String, dynamic> json) {
    return GregorianWeekday(en: json['en']);
  }
}

class PrayerData {
  final List<PrayerTime> prayerTimes;
  final DateInfo dateInfo;

  PrayerData({required this.prayerTimes, required this.dateInfo});
}

class PrayerService {
  static const String baseUrl = 'https://api.aladhan.com/v1/timingsByCity';
  static const String city = 'Dhaka';
  static const String country = 'Bangladesh';
  static const int method = 1; // University of Islamic Sciences, Karachi
  static const int school = 1; // Hanafi

  Future<PrayerData?> getPrayerTimes(String dateString) async {
    try {
      final url = '$baseUrl/$dateString?city=$city&country=$country&method=$method&school=$school';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          return _processPrayerData(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching prayer times: $e');
      return null;
    }
  }

  PrayerData _processPrayerData(Map<String, dynamic> data) {
    final timings = data['timings'];
    final dateInfo = DateInfo.fromJson(data['date']);
    
    // Extract basic timings
    final fajr = timings['Fajr'];
    final sunrise = timings['Sunrise'];
    final dhuhr = timings['Dhuhr'];
    final asr = timings['Asr'];
    final maghrib = timings['Maghrib'];
    final isha = timings['Isha'];
    final midnight = timings['Midnight'];

    List<PrayerTime> prayerTimes = [];

    // Calculate Tahajjud (Last third of night)
    final tahajjudStart = _calculateTahajjud(maghrib, fajr);
    prayerTimes.add(PrayerTime(
      name: 'Tahajjud',
      startTime: _convertTo12Hour(tahajjudStart),
      endTime: _convertTo12Hour(fajr),
      type: 'nafal',
      arabicName: 'تَهَجُّد',
    ));

    // Fajr
    prayerTimes.add(PrayerTime(
      name: 'Fajr',
      startTime: _convertTo12Hour(fajr),
      endTime: _convertTo12Hour(sunrise),
      type: 'fard',
      arabicName: 'فَجْر',
    ));

    // Prohibited Time 1 (Post-Sunrise)
    final prohibitedEnd1 = _addMinutes(sunrise, 15);
    prayerTimes.add(PrayerTime(
      name: 'Prohibited Time 1',
      startTime: _convertTo12Hour(sunrise),
      endTime: _convertTo12Hour(prohibitedEnd1),
      type: 'prohibited',
      arabicName: 'وَقْت كَرَاهَة',
    ));

    // Ishraq
    final ishraqEnd = _addMinutes(prohibitedEnd1, 20);
    prayerTimes.add(PrayerTime(
      name: 'Ishraq',
      startTime: _convertTo12Hour(prohibitedEnd1),
      endTime: _convertTo12Hour(ishraqEnd),
      type: 'nafal',
      arabicName: 'إِشْرَاق',
    ));

    // Chasht (Duha)
    final chastStart = _addMinutes(ishraqEnd, 1);
    final prohibitedStart2 = _subtractMinutes(dhuhr, 15);
    prayerTimes.add(PrayerTime(
      name: 'Chasht (Duha)',
      startTime: _convertTo12Hour(chastStart),
      endTime: _convertTo12Hour(_subtractMinutes(prohibitedStart2, 1)),
      type: 'nafal',
      arabicName: 'ضُحَى',
    ));

    // Prohibited Time 2 (Zawal)
    prayerTimes.add(PrayerTime(
      name: 'Prohibited Time 2 (Zawal)',
      startTime: _convertTo12Hour(prohibitedStart2),
      endTime: _convertTo12Hour(_subtractMinutes(dhuhr, 1)),
      type: 'prohibited',
      arabicName: 'وَقْت زَوَال',
    ));

    // Dhuhr
    prayerTimes.add(PrayerTime(
      name: 'Dhuhr',
      startTime: _convertTo12Hour(dhuhr),
      endTime: _convertTo12Hour(asr),
      type: 'fard',
      arabicName: 'ظُهْر',
    ));

    // Asr
    final prohibitedStart3 = _subtractMinutes(timings['Sunset'], 15);
    prayerTimes.add(PrayerTime(
      name: 'Asr',
      startTime: _convertTo12Hour(asr),
      endTime: _convertTo12Hour(_subtractMinutes(prohibitedStart3, 1)),
      type: 'fard',
      arabicName: 'عَصْر',
    ));

    // Prohibited Time 3 (Before Sunset)
    prayerTimes.add(PrayerTime(
      name: 'Prohibited Time 3',
      startTime: _convertTo12Hour(prohibitedStart3),
      endTime: _convertTo12Hour(timings['Sunset']),
      type: 'prohibited',
      arabicName: 'وَقْت كَرَاهَة',
    ));

    // Maghrib
    prayerTimes.add(PrayerTime(
      name: 'Maghrib',
      startTime: _convertTo12Hour(maghrib),
      endTime: _convertTo12Hour(_subtractMinutes(isha, 1)),
      type: 'fard',
      arabicName: 'مَغْرِب',
    ));

    // Awwabin
    prayerTimes.add(PrayerTime(
      name: 'Awwabin',
      startTime: _convertTo12Hour(maghrib),
      endTime: _convertTo12Hour(_subtractMinutes(isha, 1)),
      type: 'nafal',
      arabicName: 'أَوَّابِين',
    ));

    // Isha
    prayerTimes.add(PrayerTime(
      name: 'Isha',
      startTime: _convertTo12Hour(isha),
      endTime: _convertTo12Hour(midnight),
      type: 'fard',
      arabicName: 'عِشَاء',
    ));

    return PrayerData(prayerTimes: prayerTimes, dateInfo: dateInfo);
  }

  String _calculateTahajjud(String maghrib, String fajr) {
    // Calculate night duration and find last third start
    final maghribTime = _parseTime(maghrib);
    final fajrTime = _parseTime(fajr);
    
    // Handle night crossing midnight
    int nightDuration;
    if (fajrTime < maghribTime) {
      nightDuration = (1440 - maghribTime) + fajrTime; // 1440 = 24 * 60
    } else {
      nightDuration = fajrTime - maghribTime;
    }
    
    final lastThirdDuration = nightDuration ~/ 3;
    final tahajjudStart = fajrTime - lastThirdDuration;
    
    return _formatTime(tahajjudStart < 0 ? tahajjudStart + 1440 : tahajjudStart);
  }

  int _parseTime(String timeString) {
    final parts = timeString.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  String _addMinutes(String time, int minutesToAdd) {
    final totalMinutes = _parseTime(time) + minutesToAdd;
    return _formatTime(totalMinutes >= 1440 ? totalMinutes - 1440 : totalMinutes);
  }

  String _subtractMinutes(String time, int minutesToSubtract) {
    final totalMinutes = _parseTime(time) - minutesToSubtract;
    return _formatTime(totalMinutes < 0 ? totalMinutes + 1440 : totalMinutes);
  }

  String _convertTo12Hour(String time24) {
    final parts = time24.split(':');
    int hours = int.parse(parts[0]);
    final minutes = parts[1];
    
    String period = hours >= 12 ? 'PM' : 'AM';
    
    if (hours == 0) {
      hours = 12;
    } else if (hours > 12) {
      hours = hours - 12;
    }
    
    return '$hours:$minutes $period';
  }

  // Helper method to get current prayer
  PrayerTime? getCurrentPrayer(List<PrayerTime> prayers) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    for (final prayer in prayers) {
      if (_isTimeBetween(currentTime, prayer.startTime, prayer.endTime)) {
        return prayer;
      }
    }
    return null;
  }

  // Helper method to get next prayer
  PrayerTime? getNextPrayer(List<PrayerTime> prayers) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    for (final prayer in prayers.where((p) => p.type == 'fard')) {
      if (_parseTime(_convertTo24Hour(prayer.startTime)) > _parseTime(currentTime)) {
        return prayer;
      }
    }
    
    // If no prayer found for today, return first prayer of next day (Fajr)
    return prayers.where((p) => p.name == 'Fajr').first;
  }

  bool _isTimeBetween(String current, String start, String end) {
    final currentMinutes = _parseTime(current);
    final startMinutes = _parseTime(_convertTo24Hour(start));
    final endMinutes = _parseTime(_convertTo24Hour(end));
    
    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Time range crosses midnight
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  String _convertTo24Hour(String time12) {
    final parts = time12.split(' ');
    final timePart = parts[0].split(':');
    final period = parts[1];
    
    int hours = int.parse(timePart[0]);
    final minutes = timePart[1];
    
    if (period == 'AM' && hours == 12) {
      hours = 0;
    } else if (period == 'PM' && hours != 12) {
      hours = hours + 12;
    }
    
    return '${hours.toString().padLeft(2, '0')}:$minutes';
  }

  // Method to get today's prayer times
  Future<PrayerData?> getTodaysPrayerTimes() async {
    final today = DateTime.now();
    final dateString = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';
    return await getPrayerTimes(dateString);
  }
// Add this method to your PrayerService class
Future<List<FardPrayerInfo>> getTodaysFardPrayers() async {
  try {
    final prayerData = await getTodaysPrayerTimes();
    if (prayerData == null) {
      return [];
    }

    // Filter only fard prayers and extract required information
    final fardPrayers = prayerData.prayerTimes
        .where((prayer) => prayer.type == 'fard')
        .map((prayer) => FardPrayerInfo(
              name: prayer.name,
              arabicName: prayer.arabicName ?? '',
              startTime: prayer.startTime,
            ))
        .toList();

    return fardPrayers;
  } catch (e) {
    print('Error getting today\'s fard prayers: $e');
    return [];
  }
}
  // Method to get prayer times by date
  Future<PrayerData?> getPrayerTimesByDate(DateTime date) async {
    final dateString = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    return await getPrayerTimes(dateString);
  }
}

class FardPrayerInfo {
  final String name;
  final String arabicName;
  final String startTime;

  FardPrayerInfo({
    required this.name,
    required this.arabicName,
    required this.startTime,
  });

  @override
  String toString() {
    return '$name ($arabicName): $startTime';
  }
}