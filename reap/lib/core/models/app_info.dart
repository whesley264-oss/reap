class AppInfo {
  final String packageName;
  final String name;
  final int size;
  final DateTime? installDate;
  final DateTime? lastUse;
  final int usageCount;

  const AppInfo({
    required this.packageName,
    required this.name,
    required this.size,
    this.installDate,
    this.lastUse,
    this.usageCount = 0,
  });

  bool get isUnused {
    if (lastUse == null) return true;
    final daysSinceUse = DateTime.now().difference(lastUse!).inDays;
    return daysSinceUse > 30;
  }

  bool get isLarge {
    const largeThreshold = 500 * 1024 * 1024; // 500 MB
    return size > largeThreshold;
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
      lastUse: parseDate(map['lastUse']),
      usageCount: map['usageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'packageName': packageName,
        'name': name,
        'size': size,
        'installDate': installDate?.millisecondsSinceEpoch,
        'lastUse': lastUse?.millisecondsSinceEpoch,
        'usageCount': usageCount,
      };
}