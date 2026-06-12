import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/services.dart';

enum ThemeOption { light, dark, system }

class SettingsState {
  final ThemeOption themeOption;
  final int monitoringIntervalMinutes;
  final bool notificationsEnabled;

  const SettingsState({
    this.themeOption = ThemeOption.system,
    this.monitoringIntervalMinutes = 60,
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    ThemeOption? themeOption,
    int? monitoringIntervalMinutes,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      themeOption: themeOption ?? this.themeOption,
      monitoringIntervalMinutes: monitoringIntervalMinutes ?? this.monitoringIntervalMinutes,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeStr = await DatabaseService.instance.getSetting('theme');
    final intervalStr = await DatabaseService.instance.getSetting('monitoringInterval');
    final notifStr = await DatabaseService.instance.getSetting('notificationsEnabled');

    ThemeOption theme = ThemeOption.system;
    if (themeStr == 'light') theme = ThemeOption.light;
    else if (themeStr == 'dark') theme = ThemeOption.dark;

    int interval = 60;
    if (intervalStr != null) interval = int.tryParse(intervalStr) ?? 60;

    bool notifs = true;
    if (notifStr != null) notifs = notifStr == 'true';

    state = SettingsState(
      themeOption: theme,
      monitoringIntervalMinutes: interval,
      notificationsEnabled: notifs,
    );
  }

  Future<void> setTheme(ThemeOption option) async {
    String themeStr;
    switch (option) {
      case ThemeOption.light:
        themeStr = 'light';
        break;
      case ThemeOption.dark:
        themeStr = 'dark';
        break;
      case ThemeOption.system:
        themeStr = 'system';
        break;
    }
    await DatabaseService.instance.saveSetting('theme', themeStr);
    state = state.copyWith(themeOption: option);
  }

  Future<void> setMonitoringInterval(int minutes) async {
    await DatabaseService.instance.saveSetting('monitoringInterval', minutes.toString());
    state = state.copyWith(monitoringIntervalMinutes: minutes);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await DatabaseService.instance.saveSetting('notificationsEnabled', enabled.toString());
    state = state.copyWith(notificationsEnabled: enabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  switch (settings.themeOption) {
    case ThemeOption.light:
      return ThemeMode.light;
    case ThemeOption.dark:
      return ThemeMode.dark;
    case ThemeOption.system:
      return ThemeMode.system;
  }
});