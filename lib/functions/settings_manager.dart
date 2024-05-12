import 'package:flutter/services.dart';

class SettingsManager {
  static const _channel = MethodChannel('com.example.smigoal/settings');

  Future<void> setForegroundServiceEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setForegroundServiceEnabled', {'enabled': enabled});
    } on PlatformException catch (e) {
      print("Failed to set foreground service enabled: '${e.message}'.");
    }
  }

  Future<bool> isForegroundServiceEnabled() async {
    try {
      final bool isEnabled = await _channel.invokeMethod('isForegroundServiceEnabled');
      return isEnabled;
    } on PlatformException catch (e) {
      print("Failed to get foreground service enabled: '${e.message}'.");
      return false;
    }
  }

  Future<void> deleteAllInDB() async {
    try {
      await _channel.invokeMethod('deleteAllInDB');
    } on PlatformException catch (e) {
      print("Failed to delete DB: '${e.message}'.");
    }
  }
}
