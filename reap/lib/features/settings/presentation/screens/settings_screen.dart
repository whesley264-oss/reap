import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeSection(context, ref, settings),
          const SizedBox(height: 16),
          _buildMonitoringSection(context, ref, settings),
          const SizedBox(height: 16),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref, SettingsState settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 24),
                const SizedBox(width: 8),
                Text('Tema', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            RadioListTile<ThemeOption>(
              title: const Text('Claro'),
              value: ThemeOption.light,
              groupValue: settings.themeOption,
              onChanged: (value) => ref.read(settingsProvider.notifier).setTheme(value!),
            ),
            RadioListTile<ThemeOption>(
              title: const Text('Escuro'),
              value: ThemeOption.dark,
              groupValue: settings.themeOption,
              onChanged: (value) => ref.read(settingsProvider.notifier).setTheme(value!),
            ),
            RadioListTile<ThemeOption>(
              title: const Text('Sistema'),
              value: ThemeOption.system,
              groupValue: settings.themeOption,
              onChanged: (value) => ref.read(settingsProvider.notifier).setTheme(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringSection(BuildContext context, WidgetRef ref, SettingsState settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monitor_heart_outlined, size: 24),
                const SizedBox(width: 8),
                Text('Monitoramento', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            ListTile(
              title: const Text('Intervalo de monitoramento'),
              subtitle: Text('A cada ${settings.monitoringIntervalMinutes} minutos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showIntervalPicker(context, ref, settings.monitoringIntervalMinutes),
            ),
            SwitchListTile(
              title: const Text('Notificações inteligentes'),
              subtitle: const Text('Alertas sobre temperatura e armazenamento'),
              value: settings.notificationsEnabled,
              onChanged: (value) => ref.read(settingsProvider.notifier).setNotificationsEnabled(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 24),
                const SizedBox(width: 8),
                Text('Sobre', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            const ListTile(
              title: Text('REAP'),
              subtitle: Text('Seu celular, sem mistérios.'),
            ),
            const ListTile(
              title: Text('Versão'),
              subtitle: Text('1.0.0'),
            ),
            ListTile(
              title: const Text('Transparência'),
              subtitle: const Text(
                'O REAP não oferece funcionalidades falsas de "aceleração" ou "otimização". '
                'Todas as métricas são obtidas diretamente do sistema Android.',
              ),
              isThreeLine: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showIntervalPicker(BuildContext context, WidgetRef ref, int currentInterval) {
    final intervals = [15, 30, 60, 120, 240];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Intervalo de monitoramento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) {
            return RadioListTile<int>(
              title: Text(_formatInterval(interval)),
              value: interval,
              groupValue: currentInterval,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).setMonitoringInterval(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes minutos';
    final hours = minutes ~/ 60;
    return '$hours ${hours == 1 ? 'hora' : 'horas'}';
  }
}