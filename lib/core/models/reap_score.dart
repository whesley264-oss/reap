class ReapScore {
  final int score;
  final int storagePoints;
  final int batteryPoints;
  final int temperaturePoints;
  final int memoryPoints;
  final List<String> reasons;
  final DateTime timestamp;

  const ReapScore({
    required this.score,
    required this.storagePoints,
    required this.batteryPoints,
    required this.temperaturePoints,
    required this.memoryPoints,
    required this.reasons,
    required this.timestamp,
  });

  String get label {
    if (score >= 95) return 'Excelente';
    if (score >= 80) return 'Bom';
    if (score >= 60) return 'Atenção';
    return 'Crítico';
  }

  factory ReapScore.empty() => ReapScore(
        score: 0,
        storagePoints: 0,
        batteryPoints: 0,
        temperaturePoints: 0,
        memoryPoints: 0,
        reasons: [],
        timestamp: DateTime.now(),
      );

  factory ReapScore.calculate({
    required double storageFreePercent,
    required int batteryLevel,
    required double temperature,
    required double memoryUsagePercent,
  }) {
    final reasons = <String>[];
    
    // Storage points (30 max)
    int storagePoints;
    if (storageFreePercent >= 30) {
      storagePoints = 30;
    } else {
      storagePoints = ((storageFreePercent / 30) * 30).round();
      reasons.add('Armazenamento acima de 90%');
    }
    
    // Battery points (30 max)
    int batteryPoints = (batteryLevel * 0.3).round();
    
    // Temperature points (20 max)
    int temperaturePoints;
    if (temperature >= 20 && temperature <= 35) {
      temperaturePoints = 20;
    } else if (temperature > 35 && temperature <= 45) {
      temperaturePoints = 10;
      reasons.add('Temperatura média elevada');
    } else {
      temperaturePoints = 0;
      reasons.add('Temperatura crítica');
    }
    
    // Memory points (20 max)
    int memoryPoints;
    if (memoryUsagePercent <= 80) {
      memoryPoints = 20;
    } else {
      memoryPoints = ((100 - memoryUsagePercent) * 0.2).round().clamp(0, 20);
      if (memoryUsagePercent > 90) {
        reasons.add('Uso de memória muito alto');
      }
    }
    
    final total = storagePoints + batteryPoints + temperaturePoints + memoryPoints;
    
    return ReapScore(
      score: total,
      storagePoints: storagePoints,
      batteryPoints: batteryPoints,
      temperaturePoints: temperaturePoints,
      memoryPoints: memoryPoints,
      reasons: reasons,
      timestamp: DateTime.now(),
    );
  }

  factory ReapScore.fromMap(Map<String, dynamic> map) {
    final reasonsList = map['reasons'];
    List<String> parseReasons() {
      if (reasonsList == null) return [];
      if (reasonsList is List) {
        return reasonsList.cast<String>();
      }
      return [];
    }

    final timestampVal = map['timestamp'];
    DateTime parseTimestamp() {
      if (timestampVal is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestampVal);
      }
      return DateTime.now();
    }

    return ReapScore(
      score: map['score'] ?? 0,
      storagePoints: map['storagePoints'] ?? 0,
      batteryPoints: map['batteryPoints'] ?? 0,
      temperaturePoints: map['temperaturePoints'] ?? 0,
      memoryPoints: map['memoryPoints'] ?? 0,
      reasons: parseReasons(),
      timestamp: parseTimestamp(),
    );
  }

  Map<String, dynamic> toMap() => {
        'score': score,
        'storagePoints': storagePoints,
        'batteryPoints': batteryPoints,
        'temperaturePoints': temperaturePoints,
        'memoryPoints': memoryPoints,
        'reasons': reasons,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };
}