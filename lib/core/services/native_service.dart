import 'package:flutter/services.dart';
import '../models/models.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel('com.reap/native');

  static NativeService? _instance;
  static NativeService get instance => _instance ??= NativeService._();

  NativeService._();

  Future<DeviceInfo> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod('getDeviceInfo');
      if (result != null) {
        return DeviceInfo.fromMap(Map<String, dynamic>.from(result));
      }
    } on PlatformException catch (e) {
      print('Failed to get device info: ${e.message}');
    }
    return DeviceInfo.empty();
  }

  Future<BatteryInfo> getBatteryInfo() async {
    try {
      final result = await _channel.invokeMethod('getBatteryInfo');
      if (result != null) {
        return BatteryInfo.fromMap(Map<String, dynamic>.from(result));
      }
    } on PlatformException catch (e) {
      print('Failed to get battery info: ${e.message}');
    }
    return BatteryInfo.empty();
  }

  Future<List<StorageCategoryInfo>> getStorageAnalysis() async {
    try {
      final result = await _channel.invokeMethod('getStorageAnalysis');
      if (result != null && result is List) {
        return result.map((e) => StorageCategoryInfo.fromMap(Map<String, dynamic>.from(e))).toList();
      }
    } on PlatformException catch (e) {
      print('Failed to get storage analysis: ${e.message}');
    }
    return [];
  }

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod('getInstalledApps');
      if (result != null && result is List) {
        return result.map((e) => AppInfo.fromMap(Map<String, dynamic>.from(e))).toList();
      }
    } on PlatformException catch (e) {
      print('Failed to get installed apps: ${e.message}');
    }
    return [];
  }
}