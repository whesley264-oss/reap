enum BatteryStatus {
  charging,
  discharging,
  full,
  notCharging,
  unknown,
}

enum HealthConfidence {
  low,
  medium,
  high,
}

class BatteryInfo {
  final int level;
  final double temperature;
  final BatteryStatus status;
  final int voltage;
  final String technology;
  final int? estimatedHealth;
  final HealthConfidence healthConfidence;

  const BatteryInfo({
    required this.level,
    required this.temperature,
    required this.status,
    required this.voltage,
    required this.technology,
    this.estimatedHealth,
    this.healthConfidence = HealthConfidence.low,
  });

  String get healthDescription {
    if (estimatedHealth == null) return 'Indisponível';
    if (estimatedHealth! >= 90) return 'Excelente';
    if (estimatedHealth! >= 70) return 'Boa';
    if (estimatedHealth! >= 50) return 'Regular';
    return 'Atenção';
  }

  String get temperatureDescription {
    if (temperature < 20) return 'Baixa';
    if (temperature < 35) return 'Normal';
    if (temperature < 45) return 'Elevada';
    return 'Crítica';
  }

  factory BatteryInfo.empty() => const BatteryInfo(
        level: 0,
        temperature: 0,
        status: BatteryStatus.unknown,
        voltage: 0,
        technology: 'Unknown',
      );

  factory BatteryInfo.fromMap(Map<String, dynamic> map) {
    BatteryStatus parseStatus(String? s) {
      switch (s) {
        case 'charging':
          return BatteryStatus.charging;
        case 'discharging':
          return BatteryStatus.discharging;
        case 'full':
          return BatteryStatus.full;
        case 'notCharging':
          return BatteryStatus.notCharging;
        default:
          return BatteryStatus.unknown;
      }
    }

    HealthConfidence parseConfidence(String? c) {
      switch (c) {
        case 'low':
          return HealthConfidence.low;
        case 'medium':
          return HealthConfidence.medium;
        case 'high':
          return HealthConfidence.high;
        default:
          return HealthConfidence.low;
      }
    }

    return BatteryInfo(
      level: map['level'] ?? 0,
      temperature: (map['temperature'] ?? 0).toDouble(),
      status: parseStatus(map['status']),
      voltage: map['voltage'] ?? 0,
      technology: map['technology'] ?? 'Unknown',
      estimatedHealth: map['estimatedHealth'],
      healthConfidence: parseConfidence(map['healthConfidence']),
    );
  }

  Map<String, dynamic> toMap() => {
        'level': level,
        'temperature': temperature,
        'status': status.name,
        'voltage': voltage,
        'technology': technology,
        'estimatedHealth': estimatedHealth,
        'healthConfidence': healthConfidence.name,
      };
}