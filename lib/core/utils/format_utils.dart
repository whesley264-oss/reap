class FormatUtils {
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '$days dia${days > 1 ? 's' : ''}, $hours h';
    }
    if (hours > 0) {
      return '$hours h, $minutes min';
    }
    return '$minutes min';
  }

  static String formatUptime(int uptimeSeconds) {
    return formatDuration(Duration(seconds: uptimeSeconds));
  }

  static String formatTemperature(double temp) {
    return '${temp.toStringAsFixed(1)}°C';
  }

  static String formatPercent(double percent) {
    return '${percent.toStringAsFixed(1)}%';
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String daysAgo(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Hoje';
    if (days == 1) return 'Ontem';
    if (days < 7) return 'Há $days dias';
    if (days < 30) return 'Há ${(days / 7).floor()} semanas';
    return 'Há ${(days / 30).floor()} meses';
  }
}