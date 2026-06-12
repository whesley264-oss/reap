import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../dashboard/providers/device_provider.dart';

class BatteryScreen extends ConsumerWidget {
  const BatteryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryAsync = ref.watch(batteryInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bateria')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(batteryInfoProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBatteryLevelCard(context, batteryAsync),
              const SizedBox(height: 16),
              _buildBatteryDetailsCard(context, batteryAsync),
              const SizedBox(height: 16),
              _buildHealthCard(context, batteryAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryLevelCard(BuildContext context, AsyncValue<BatteryInfo> batteryAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: batteryAsync.when(
          data: (battery) {
            Color levelColor;
            IconData levelIcon;
            String levelText;

            if (battery.level >= 80) {
              levelColor = AppColors.success;
              levelIcon = Icons.battery_full;
              levelText = 'Carregada';
            } else if (battery.level >= 50) {
              levelColor = AppColors.success;
              levelIcon = Icons.battery_5_bar;
              levelText = 'Boa';
            } else if (battery.level >= 20) {
              levelColor = AppColors.warning;
              levelIcon = Icons.battery_3_bar;
              levelText = 'Baixa';
            } else {
              levelColor = AppColors.error;
              levelIcon = Icons.battery_1_bar;
              levelText = 'Crítica';
            }

            return Column(
              children: [
                Icon(levelIcon, size: 64, color: levelColor),
                const SizedBox(height: 16),
                Text(
                  '${battery.level}%',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(levelText, style: TextStyle(color: levelColor)),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Erro ao carregar dados da bateria'),
        ),
      ),
    );
  }

  Widget _buildBatteryDetailsCard(BuildContext context, AsyncValue<BatteryInfo> batteryAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text('Detalhes', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            batteryAsync.when(
              data: (battery) {
                String statusText;
                switch (battery.status) {
                  case BatteryStatus.charging:
                    statusText = 'Carregando';
                    break;
                  case BatteryStatus.discharging:
                    statusText = 'Descarregando';
                    break;
                  case BatteryStatus.full:
                    statusText = 'Completa';
                    break;
                  case BatteryStatus.notCharging:
                    statusText = 'Não carregando';
                    break;
                  default:
                    statusText = 'Desconhecido';
                }

                return Column(
                  children: [
                    _buildDetailRow('Temperatura', FormatUtils.formatTemperature(battery.temperature), _getTempColor(battery.temperature)),
                    _buildDetailRow('Status', statusText, AppColors.primary),
                    _buildDetailRow('Voltagem', '${battery.voltage} mV', AppColors.primary),
                    _buildDetailRow('Tecnologia', battery.technology, AppColors.primary),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar detalhes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, AsyncValue<BatteryInfo> batteryAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_outline, size: 20),
                const SizedBox(width: 8),
                Text('Saúde Estimada', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            batteryAsync.when(
              data: (battery) {
                if (battery.estimatedHealth == null) {
                  return const Text('Dados de saúde não disponíveis');
                }

                String confidenceText;
                Color confidenceColor;
                switch (battery.healthConfidence) {
                  case HealthConfidence.high:
                    confidenceText = 'Alta';
                    confidenceColor = AppColors.success;
                    break;
                  case HealthConfidence.medium:
                    confidenceText = 'Média';
                    confidenceColor = AppColors.warning;
                    break;
                  case HealthConfidence.low:
                    confidenceText = 'Baixa';
                    confidenceColor = AppColors.error;
                    break;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${battery.estimatedHealth}%',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getHealthColor(battery.estimatedHealth!),
                              ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nível de confiança:'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: confidenceColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(confidenceText, style: TextStyle(color: confidenceColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A saúde estimada é baseada na observação de padrões de carregamento ao longo do tempo. Este valor não é absoluto e deve ser considerado como uma referência.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar saúde estimada'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: valueColor)),
        ],
      ),
    );
  }

  Color _getTempColor(double temp) {
    if (temp < 20) return AppColors.warning;
    if (temp <= 35) return AppColors.success;
    if (temp <= 45) return AppColors.warning;
    return AppColors.error;
  }

  Color _getHealthColor(int health) {
    if (health >= 90) return AppColors.success;
    if (health >= 70) return AppColors.scoreGood;
    if (health >= 50) return AppColors.warning;
    return AppColors.error;
  }
}