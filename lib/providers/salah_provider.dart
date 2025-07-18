// providers/salah_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/prayer_time.dart';
import '../models/salah_data.dart'; // Added missing import
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
    _init();
  }

  Future<void> _init() async {
    try {
      _salahBox = Hive.box('salah_tracker');
      _loadTodaysCompletions();
      await _loadPrayerTimes();
    } catch (e) {
      _error = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPrayerTimes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final prayerTimeService = PrayerTimeService();
      _prayerTimes = await prayerTimeService.getTodaysPrayerTimes();
      
      // Schedule notifications for each prayer
      final notificationService = NotificationService();
      for (var prayer in _prayerTimes) {
        await notificationService.schedulePrayerNotification(
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
      try {
        final salahData = SalahData.fromJson(Map<String, dynamic>.from(data));
        _todaysCompletions = Map<String, bool>.from(salahData.prayers);
      } catch (e) {
        // If data is corrupted, reset to default
        _resetTodaysCompletions();
      }
    } else {
      _resetTodaysCompletions();
    }
  }

  void _resetTodaysCompletions() {
    _todaysCompletions = {
      'Fajr': false,
      'Dhuhr': false,
      'Asr': false,
      'Maghrib': false,
      'Isha': false,
    };
  }

  Future<void> togglePrayerCompletion(String prayerName) async {
    if (!_todaysCompletions.containsKey(prayerName)) {
      return; // Invalid prayer name
    }

    _todaysCompletions[prayerName] = !_todaysCompletions[prayerName]!;
    
    // Save to local storage
    await _saveTodaysData();
    
    // Handle DND mode
    if (_todaysCompletions[prayerName]!) {
      try {
        await DndService.enableDnd();
        // Schedule to disable DND after 30 minutes
        Future.delayed(const Duration(minutes: 30), () async {
          try {
            await DndService.disableDnd();
          } catch (e) {
            debugPrint('Failed to disable DND: $e');
          }
        });
      } catch (e) {
        debugPrint('Failed to enable DND: $e');
      }
    }
    
    notifyListeners();
  }

  Future<void> _saveTodaysData() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final completedCount = _todaysCompletions.values.where((v) => v).length;
      
      final salahData = SalahData(
        date: today,
        prayers: _todaysCompletions,
        completedCount: completedCount,
      );
      
      await _salahBox.put(today, salahData.toJson());
    } catch (e) {
      debugPrint('Failed to save today\'s data: $e');
    }
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
        try {
          weeklyData.add(SalahData.fromJson(Map<String, dynamic>.from(data)));
        } catch (e) {
          // If data is corrupted, add default entry
          weeklyData.add(_createDefaultSalahData(dateString));
        }
      } else {
        weeklyData.add(_createDefaultSalahData(dateString));
      }
    }
    
    return weeklyData;
  }

  SalahData _createDefaultSalahData(String date) {
    return SalahData(
      date: date,
      prayers: {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
      },
      completedCount: 0,
    );
  }

  String getNextPrayerName() {
    if (_prayerTimes.isEmpty) return 'Loading...';
    
    try {
      final prayerTimeService = PrayerTimeService();
      return prayerTimeService.getNextPrayerName(_prayerTimes);
    } catch (e) {
      return 'Error loading next prayer';
    }
  }

  DateTime? getNextPrayerTime() {
    if (_prayerTimes.isEmpty) return null;
    
    try {
      final prayerTimeService = PrayerTimeService();
      return prayerTimeService.getNextPrayerTime(_prayerTimes);
    } catch (e) {
      return null;
    }
  }

  // Method to refresh prayer times
  Future<void> refreshPrayerTimes() async {
    await _loadPrayerTimes();
  }

  // Method to clear all data (for testing or reset purposes)
  Future<void> clearAllData() async {
    try {
      await _salahBox.clear();
      _resetTodaysCompletions();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to clear data: $e');
    }
  }
}