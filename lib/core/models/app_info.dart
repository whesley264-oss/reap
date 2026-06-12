class AppInfo {
  final String packageName;
  final String name;
  final int size;
  final DateTime? installDate;
  final DateTime? lastUpdate;
  final String version;
  final int versionCode;
  final bool isSystemApp;

  const AppInfo({
    required this.packageName,
    required this.name,
    required this.size,
    this.installDate,
    this.lastUpdate,
    this.version = 'Unknown',
    this.versionCode = 0,
    this.isSystemApp = false,
  });

  bool get isUnused {
    if (lastUpdate == null) return false;
    final daysSinceUpdate = DateTime.now().difference(lastUpdate!).inDays;
    return daysSinceUpdate > 90;
  }

  bool get isLarge {
    const largeThreshold = 500 * 1024 * 1024; // 500 MB
    return size > largeThreshold;
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  factory AppInfo.empty() => const AppInfo(
        packageName: '',
        name: 'Unknown',
        size: 0,
      );

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    }

    return AppInfo(
      packageName: map['packageName'] ?? '',
      name: map['name'] ?? 'Unknown',
      size: map['size'] ?? 0,
      installDate: parseDate(map['installDate']),
      lastUpdate: parseDate(map['lastUpdate']),
      version: map['version'] ?? 'Unknown',
      versionCode: map['versionCode'] ?? 0,
      isSystemApp: map['isSystemApp'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'packageName': packageName,
        'name': name,
        'size': size,
        'installDate': installDate?.millisecondsSinceEpoch,
        'lastUpdate': lastUpdate?.millisecondsSinceEpoch,
        'version': version,
        'versionCode': versionCode,
        'isSystemApp': isSystemApp,
      };
}