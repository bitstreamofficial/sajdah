// services/dnd_service.dart
import 'package:flutter/services.dart';

class DndService {
  static const MethodChannel _channel = MethodChannel('salah_app/dnd');

  static Future<void> enableDnd() async {
    try {
      await _channel.invokeMethod('enableDnd');
    } on PlatformException catch (e) {
      print('Failed to enable DND: ${e.message}');
    }
  }

  static Future<void> disableDnd() async {
    try {
      await _channel.invokeMethod('disableDnd');
    } on PlatformException catch (e) {
      print('Failed to disable DND: ${e.message}');
    }
  }

  static Future<bool> isDndEnabled() async {
    try {
      final result = await _channel.invokeMethod('isDndEnabled');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to check DND status: ${e.message}');
      return false;
    }
  }
}