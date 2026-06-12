import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../shared/widgets/info_card.dart';
import '../../../../shared/widgets/score_display.dart';
import '../../providers/device_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(deviceInfoProvider);
    final batteryAsync = ref.watch(batteryInfoProvider);
    final scoreAsync = ref.watch(reapScoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('REAP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(deviceInfoProvider);
          ref.invalidate(batteryInfoProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildScoreCard(context, scoreAsync),
              const SizedBox(height: 16),
              _buildQuickStats(context, deviceAsync, batteryAsync),
              const SizedBox(height: 16),
              _buildDeviceSummary(context, deviceAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, AsyncValue<ReapScore> scoreAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Reap Score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            scoreAsync.when(
              data: (score) => ScoreDisplay(score: score.score, label: score.label),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const ScoreDisplay(score: 0, label: 'Erro'),
            ),
            const SizedBox(height: 16),
            scoreAsync.when(
              data: (score) {
                if (score.reasons.isEmpty) {
                  return const Text(
                    'Dispositivo em bom estado',
                    style: TextStyle(color: AppColors.success),
                  );
                }
                return Column(
                  children: [
                    const Text(
                      'Sua nota caiu porque:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...score.reasons.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber, size: 16, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Text(r),
                            ],
                          ),
                        )),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    AsyncValue<DeviceInfo> deviceAsync,
    AsyncValue<BatteryInfo> batteryAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: deviceAsync.when(
            data: (device) => InfoCard(
              title: 'RAM',
              value: FormatUtils.formatPercent(device.ramUsagePercent),
              subtitle: '${FormatUtils.formatBytes(device.freeRam)} livre',
              icon: Icons.memory,
              iconColor: device.ramUsagePercent > 90 ? AppColors.error : AppColors.primary,
            ),
            loading: () => const InfoCard(title: 'RAM', value: '...', subtitle: 'Carregando'),
            error: (_, __) => const InfoCard(title: 'RAM', value: 'Erro'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: deviceAsync.when(
            data: (device) => InfoCard(
              title: 'Armazenamento',
              value: FormatUtils.formatPercent(device.storageUsagePercent),
              subtitle: '${FormatUtils.formatBytes(device.freeStorage)} livre',
              icon: Icons.storage,
              iconColor: device.storageUsagePercent > 90 ? AppColors.error : AppColors.primary,
            ),
            loading: () => const InfoCard(title: 'Armazenamento', value: '...', subtitle: 'Carregando'),
            error: (_, __) => const InfoCard(title: 'Armazenamento', value: 'Erro'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsBottom(
    BuildContext context,
    AsyncValue<BatteryInfo> batteryAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: batteryAsync.when(
            data: (battery) => InfoCard(
              title: 'Bateria',
              value: '${battery.level}%',
              subtitle: battery.healthDescription,
              icon: Icons.battery_std,
              iconColor: battery.level < 20 ? AppColors.error : AppColors.success,
            ),
            loading: () => const InfoCard(title: 'Bateria', value: '...', subtitle: 'Carregando'),
            error: (_, __) => const InfoCard(title: 'Bateria', value: 'Erro'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: batteryAsync.when(
            data: (battery) => InfoCard(
              title: 'Temperatura',
              value: FormatUtils.formatTemperature(battery.temperature),
              subtitle: battery.temperatureDescription,
              icon: Icons.thermostat,
              iconColor: battery.temperature > 45 ? AppColors.error : AppColors.primary,
            ),
            loading: () => const InfoCard(title: 'Temperatura', value: '...', subtitle: 'Carregando'),
            error: (_, __) => const InfoCard(title: 'Temperatura', value: 'Erro'),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSummary(BuildContext context, AsyncValue<DeviceInfo> deviceAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_android, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Resumo do Aparelho',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            deviceAsync.when(
              data: (device) => Column(
                children: [
                  _buildInfoRow('Modelo', device.model),
                  _buildInfoRow('Fabricante', device.manufacturer),
                  _buildInfoRow('Android', device.androidVersion),
                  _buildInfoRow('API', '${device.apiLevel}'),
                  _buildInfoRow('RAM Total', FormatUtils.formatBytes(device.totalRam)),
                  _buildInfoRow('Armazenamento Total', FormatUtils.formatBytes(device.totalStorage)),
                  _buildInfoRow('Tempo Ligado', FormatUtils.formatUptime(device.uptime)),
                  _buildInfoRow('CPU', '${device.cpuArchitecture} (${device.cpuCores} cores)'),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar informações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}