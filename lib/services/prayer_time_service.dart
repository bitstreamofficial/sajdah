// services/prayer_time_service.dart
import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_time.dart';

class PrayerTimeService {
  static const List<String> prayerNames = [
    'Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'
  ];

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<PrayerTime>> getTodaysPrayerTimes() async {
    try {
      Position position = await getCurrentLocation();
      
      final coordinates = Coordinates(position.latitude, position.longitude);
      final calculationParameters = CalculationParameters(
        method: CalculationMethod.MuslimWorldLeague,
        madhab: Madhab.Shafi,
      );

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: DateTime.now(),
        calculationParameters: calculationParameters,
      );

      return [
        PrayerTime(name: 'Fajr', time: prayerTimes.fajr),
        PrayerTime(name: 'Dhuhr', time: prayerTimes.dhuhr),
        PrayerTime(name: 'Asr', time: prayerTimes.asr),
        PrayerTime(name: 'Maghrib', time: prayerTimes.maghrib),
        PrayerTime(name: 'Isha', time: prayerTimes.isha),
      ];
    } catch (e) {
      throw Exception('Failed to get prayer times: $e');
    }
  }

  String getNextPrayerName(List<PrayerTime> prayerTimes) {
    final now = DateTime.now();
    
    for (var prayer in prayerTimes) {
      if (prayer.time.isAfter(now)) {
        return prayer.name;
      }
    }
    
    // If no prayer is left today, return Fajr (next day)
    return 'Fajr';
  }

  DateTime? getNextPrayerTime(List<PrayerTime> prayerTimes) {
    final now = DateTime.now();
    
    for (var prayer in prayerTimes) {
      if (prayer.time.isAfter(now)) {
        return prayer.time;
      }
    }
    
    return null; // No more prayers today
  }
}