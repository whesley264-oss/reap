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

  Future<int> getAndroidVersion() async {
    try {
      final result = await _channel.invokeMethod('getAndroidVersion');
      return result as int? ?? 0;
    } on PlatformException {
      return 0;
    }
  }

  Future<bool> hasStoragePermission() async {
    try {
      final result = await _channel.invokeMethod('hasStoragePermission');
      return result as bool? ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> requestStoragePermission() async {
    try {
      await _channel.invokeMethod('requestStoragePermission');
    } on PlatformException catch (e) {
      print('Failed to request storage permission: ${e.message}');
    }
  }

  Future<void> openAppSettings(String packageName) async {
    try {
      await _channel.invokeMethod('openAppSettings', {'packageName': packageName});
    } on PlatformException catch (e) {
      print('Failed to open app settings: ${e.message}');
    }
  }

  Future<void> openFileLocation(String path) async {
    try {
      await _channel.invokeMethod('openFileLocation', {'path': path});
    } on PlatformException catch (e) {
      print('Failed to open file location: ${e.message}');
    }
  }

  Future<void> openDownloads() async {
    try {
      await _channel.invokeMethod('openDownloads');
    } on PlatformException catch (e) {
      print('Failed to open downloads: ${e.message}');
    }
  }
}