class DeviceInfo {
  final String model;
  final String manufacturer;
  final String androidVersion;
  final int apiLevel;
  final int totalRam;
  final int freeRam;
  final int totalStorage;
  final int freeStorage;
  final int uptime;
  final String cpuArchitecture;
  final int cpuCores;
  final bool hasStoragePermission;

  const DeviceInfo({
    required this.model,
    required this.manufacturer,
    required this.androidVersion,
    required this.apiLevel,
    required this.totalRam,
    required this.freeRam,
    required this.totalStorage,
    required this.freeStorage,
    required this.uptime,
    required this.cpuArchitecture,
    required this.cpuCores,
    this.hasStoragePermission = false,
  });

  double get ramUsagePercent => totalRam > 0 ? ((totalRam - freeRam) / totalRam) * 100 : 0;
  double get storageUsagePercent => totalStorage > 0 ? ((totalStorage - freeStorage) / totalStorage) * 100 : 0;

  factory DeviceInfo.empty() => const DeviceInfo(
        model: 'Unknown',
        manufacturer: 'Unknown',
        androidVersion: 'Unknown',
        apiLevel: 0,
        totalRam: 0,
        freeRam: 0,
        totalStorage: 0,
        freeStorage: 0,
        uptime: 0,
        cpuArchitecture: 'Unknown',
        cpuCores: 0,
        hasStoragePermission: false,
      );

  factory DeviceInfo.fromMap(Map<String, dynamic> map) => DeviceInfo(
        model: map['model'] ?? 'Unknown',
        manufacturer: map['manufacturer'] ?? 'Unknown',
        androidVersion: map['androidVersion'] ?? 'Unknown',
        apiLevel: map['apiLevel'] ?? 0,
        totalRam: map['totalRam'] ?? 0,
        freeRam: map['freeRam'] ?? 0,
        totalStorage: map['totalStorage'] ?? 0,
        freeStorage: map['freeStorage'] ?? 0,
        uptime: map['uptime'] ?? 0,
        cpuArchitecture: map['cpuArchitecture'] ?? 'Unknown',
        cpuCores: map['cpuCores'] ?? 0,
        hasStoragePermission: map['hasStoragePermission'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'model': model,
        'manufacturer': manufacturer,
        'androidVersion': androidVersion,
        'apiLevel': apiLevel,
        'totalRam': totalRam,
        'freeRam': freeRam,
        'totalStorage': totalStorage,
        'freeStorage': freeStorage,
        'uptime': uptime,
        'cpuArchitecture': cpuArchitecture,
        'cpuCores': cpuCores,
        'hasStoragePermission': hasStoragePermission,
      };
}