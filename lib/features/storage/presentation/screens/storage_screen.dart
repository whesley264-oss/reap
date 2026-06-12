import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../shared/widgets/storage_indicator.dart';
import '../../../dashboard/providers/device_provider.dart';

class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(deviceInfoProvider);
    final storageAsync = ref.watch(storageAnalysisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Armazenamento')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(deviceInfoProvider);
          ref.invalidate(storageAnalysisProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStorageOverview(context, deviceAsync),
              const SizedBox(height: 16),
              _buildCategoriesCard(context, storageAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageOverview(BuildContext context, AsyncValue<DeviceInfo> deviceAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: deviceAsync.when(
          data: (device) {
            final usedStorage = device.totalStorage - device.freeStorage;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storage, size: 24, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Visão Geral', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                StorageIndicator(
                  percent: device.storageUsagePercent,
                  label: 'Usado',
                  value: '${FormatUtils.formatBytes(usedStorage)} de ${FormatUtils.formatBytes(device.totalStorage)}',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStorageStat('Total', FormatUtils.formatBytes(device.totalStorage)),
                    _buildStorageStat('Usado', FormatUtils.formatBytes(usedStorage)),
                    _buildStorageStat('Livre', FormatUtils.formatBytes(device.freeStorage)),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Erro ao carregar informações de armazenamento'),
        ),
      ),
    );
  }

  Widget _buildStorageStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesCard(BuildContext context, AsyncValue<List<StorageCategoryInfo>> storageAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.folder_outlined, size: 24, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Categorias', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            storageAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhum dado de categoria disponível'),
                  );
                }

                final totalSize = categories.fold<int>(0, (sum, cat) => sum + cat.size);

                return Column(
                  children: categories.map((cat) {
                    final percentage = totalSize > 0 ? (cat.size / totalSize) * 100 : 0.0;
                    return _buildCategoryItem(context, cat, percentage);
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar categorias'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, StorageCategoryInfo cat, double percentage) {
    IconData icon;
    Color color;

    switch (cat.category) {
      case StorageCategory.videos:
        icon = Icons.videocam;
        color = Colors.red;
        break;
      case StorageCategory.images:
        icon = Icons.image;
        color = Colors.green;
        break;
      case StorageCategory.downloads:
        icon = Icons.download;
        color = Colors.blue;
        break;
      case StorageCategory.documents:
        icon = Icons.description;
        color = Colors.orange;
        break;
      case StorageCategory.audio:
        icon = Icons.music_note;
        color = Colors.purple;
        break;
      case StorageCategory.apks:
        icon = Icons.android;
        color = Colors.teal;
        break;
      default:
        icon = Icons.folder;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.category.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FormatUtils.formatBytes(cat.size),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${cat.count} arquivos',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}