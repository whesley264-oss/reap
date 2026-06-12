enum StorageCategory {
  videos,
  images,
  downloads,
  documents,
  audio,
  apks,
  alarms,
  other,
  permissionRequired,
}

extension StorageCategoryExtension on StorageCategory {
  String get displayName {
    switch (this) {
      case StorageCategory.videos:
        return 'Vídeos';
      case StorageCategory.images:
        return 'Imagens';
      case StorageCategory.downloads:
        return 'Downloads';
      case StorageCategory.documents:
        return 'Documentos';
      case StorageCategory.audio:
        return 'Áudio';
      case StorageCategory.apks:
        return 'APKs';
      case StorageCategory.alarms:
        return 'Alarmes';
      case StorageCategory.other:
        return 'Outros';
      case StorageCategory.permissionRequired:
        return 'Permissão Necessária';
    }
  }
}

class StorageCategoryInfo {
  final StorageCategory category;
  final int size;
  final int count;
  final double percentage;
  final String? message;

  const StorageCategoryInfo({
    required this.category,
    required this.size,
    required this.count,
    required this.percentage,
    this.message,
  });

  factory StorageCategoryInfo.empty(StorageCategory cat) => StorageCategoryInfo(
        category: cat,
        size: 0,
        count: 0,
        percentage: 0,
      );

  factory StorageCategoryInfo.fromMap(Map<String, dynamic> map) {
    final catStr = map['category'] as String?;
    StorageCategory cat;
    switch (catStr) {
      case 'videos':
        cat = StorageCategory.videos;
        break;
      case 'images':
        cat = StorageCategory.images;
        break;
      case 'downloads':
        cat = StorageCategory.downloads;
        break;
      case 'documents':
        cat = StorageCategory.documents;
        break;
      case 'audio':
        cat = StorageCategory.audio;
        break;
      case 'apks':
        cat = StorageCategory.apks;
        break;
      case 'alarms':
        cat = StorageCategory.alarms;
        break;
      case 'permission_required':
        cat = StorageCategory.permissionRequired;
        break;
      default:
        cat = StorageCategory.other;
    }
    return StorageCategoryInfo(
      category: cat,
      size: map['size'] ?? 0,
      count: map['count'] ?? 0,
      percentage: (map['percentage'] ?? 0).toDouble(),
      message: map['message'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'category': category.name,
        'size': size,
        'count': count,
        'percentage': percentage,
        if (message != null) 'message': message,
      };
}