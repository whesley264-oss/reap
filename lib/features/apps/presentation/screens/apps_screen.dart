import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../dashboard/providers/device_provider.dart';

enum AppSortOption {
  sizeDesc,
  sizeAsc,
  name,
  installDate,
  lastUse,
}

class AppsScreen extends ConsumerStatefulWidget {
  const AppsScreen({super.key});

  @override
  ConsumerState<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends ConsumerState<AppsScreen> {
  AppSortOption _sortOption = AppSortOption.sizeDesc;

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(installedAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplicativos'),
        actions: [
          PopupMenuButton<AppSortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) => setState(() => _sortOption = option),
            itemBuilder: (context) => [
              const PopupMenuItem(value: AppSortOption.sizeDesc, child: Text('Maior tamanho')),
              const PopupMenuItem(value: AppSortOption.sizeAsc, child: Text('Menor tamanho')),
              const PopupMenuItem(value: AppSortOption.name, child: Text('Nome')),
              const PopupMenuItem(value: AppSortOption.installDate, child: Text('Data instalação')),
              const PopupMenuItem(value: AppSortOption.lastUse, child: Text('Último uso')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(installedAppsProvider),
        child: appsAsync.when(
          data: (apps) {
            final sortedApps = _sortApps(apps);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedApps.length,
              itemBuilder: (context, index) => _buildAppItem(context, sortedApps[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Erro ao carregar aplicativos')),
        ),
      ),
    );
  }

  List<AppInfo> _sortApps(List<AppInfo> apps) {
    final sorted = List<AppInfo>.from(apps);
    switch (_sortOption) {
      case AppSortOption.sizeDesc:
        sorted.sort((a, b) => b.size.compareTo(a.size));
        break;
      case AppSortOption.sizeAsc:
        sorted.sort((a, b) => a.size.compareTo(b.size));
        break;
      case AppSortOption.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case AppSortOption.installDate:
        sorted.sort((a, b) {
          final aDate = a.installDate ?? DateTime(1970);
          final bDate = b.installDate ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        break;
      case AppSortOption.lastUse:
        sorted.sort((a, b) {
          final aDate = a.lastUpdate ?? DateTime(1970);
          final bDate = b.lastUpdate ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        break;
    }
    return sorted;
  }

  Widget _buildAppItem(BuildContext context, AppInfo app) {
    final isLarge = app.isLarge;
    final isUnused = app.isUnused;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.android, color: AppColors.primary),
        ),
        title: Text(
          app.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(FormatUtils.formatBytes(app.size)),
            if (app.installDate != null)
              Text(
                'Instalado: ${FormatUtils.formatDate(app.installDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLarge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Grande', style: TextStyle(fontSize: 10, color: AppColors.warning)),
              ),
            if (isUnused) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Sem uso', style: TextStyle(fontSize: 10, color: AppColors.error)),
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}