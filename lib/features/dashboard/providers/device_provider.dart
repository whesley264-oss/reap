import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/services/services.dart';

final deviceInfoProvider = FutureProvider<DeviceInfo>((ref) async {
  final nativeService = NativeService.instance;
  return await nativeService.getDeviceInfo();
});

final batteryInfoProvider = FutureProvider<BatteryInfo>((ref) async {
  final nativeService = NativeService.instance;
  return await nativeService.getBatteryInfo();
});

final storageAnalysisProvider = FutureProvider<List<StorageCategoryInfo>>((ref) async {
  final nativeService = NativeService.instance;
  return await nativeService.getStorageAnalysis();
});

final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final nativeService = NativeService.instance;
  return await nativeService.getInstalledApps();
});

final reapScoreProvider = FutureProvider<ReapScore>((ref) async {
  final deviceAsync = ref.watch(deviceInfoProvider);
  final batteryAsync = ref.watch(batteryInfoProvider);

  final device = deviceAsync.valueOrNull;
  final battery = batteryAsync.valueOrNull;

  if (device == null || battery == null) {
    return ReapScore.empty();
  }

  final storageFreePercent = (device.freeStorage / device.totalStorage) * 100;
  final memoryUsagePercent = ((device.totalRam - device.freeRam) / device.totalRam) * 100;

  return ReapScore.calculate(
    storageFreePercent: storageFreePercent,
    batteryLevel: battery.level,
    temperature: battery.temperature,
    memoryUsagePercent: memoryUsagePercent,
  );
});