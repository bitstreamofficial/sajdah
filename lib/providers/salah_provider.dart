// providers/salah_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/prayer_time.dart';
import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';
import '../services/dnd_service.dart';

class SalahProvider extends ChangeNotifier {
  List<PrayerTime> _prayerTimes = [];
  bool _isLoading = false;
  String _error = '';
  Map<String, bool> _todaysCompletions = {};
  late Box _salahBox;

  List<PrayerTime> get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String get error => _error;
  Map<String, bool> get todaysCompletions => _todaysCompletions;

  SalahProvider() {
    _salahBox = Hive.box('salah_tracker');
    _loadTodaysCompletions();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final prayerTimeService = PrayerTimeService();
      _prayerTimes = await prayerTimeService.getTodaysPrayerTimes();
      
      // Schedule notifications for each prayer
      for (var prayer in _prayerTimes) {
        await NotificationService().schedulePrayerNotification(
          prayer.name,
          prayer.time,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadTodaysCompletions() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final data = _salahBox.get(today);
    
    if (data != null) {
      final salahData = SalahData.fromJson(Map<String, dynamic>.from(data));
      _todaysCompletions = salahData.prayers;
    } else {
      _todaysCompletions = {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
      };
    }
  }

  Future<void> togglePrayerCompletion(String prayerName) async {
    _todaysCompletions[prayerName] = !_todaysCompletions[prayerName]!;
    
    // Save to local storage
    await _saveTodaysData();
    
    // Handle DND mode
    if (_todaysCompletions[prayerName]!) {
      await DndService.enableDnd();
      // Schedule to disable DND after 30 minutes
      Future.delayed(const Duration(minutes: 30), () async {
        await DndService.disableDnd();
      });
    }
    
    notifyListeners();
  }

  Future<void> _saveTodaysData() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final completedCount = _todaysCompletions.values.where((v) => v).length;
    
    final salahData = SalahData(
      date: today,
      prayers: _todaysCompletions,
      completedCount: completedCount,
    );
    
    await _salahBox.put(today, salahData.toJson());
  }

  int get todaysCompletedCount {
    return _todaysCompletions.values.where((v) => v).length;
  }

  double get todaysProgress {
    return todaysCompletedCount / 5.0;
  }

  List<SalahData> getWeeklyStats() {
    final weeklyData = <SalahData>[];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final data = _salahBox.get(dateString);
      
      if (data != null) {
        weeklyData.add(SalahData.fromJson(Map<String, dynamic>.from(data)));
      } else {
        weeklyData.add(SalahData(
          date: dateString,
          prayers: {
            'Fajr': false,
            'Dhuhr': false,
            'Asr': false,
            'Maghrib': false,
            'Isha': false,
          },
          completedCount: 0,
        ));
      }
    }
    
    return weeklyData;
  }

  String getNextPrayerName() {
    if (_prayerTimes.isEmpty) return 'Loading...';
    
    final prayerTimeService = PrayerTimeService();
    return prayerTimeService.getNextPrayerName(_prayerTimes);
  }

  DateTime? getNextPrayerTime() {
    if (_prayerTimes.isEmpty) return null;
    
    final prayerTimeService = PrayerTimeService();
    return prayerTimeService.getNextPrayerTime(_prayerTimes);
  }
}