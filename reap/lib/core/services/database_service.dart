import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();

  DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'reap.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE metrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        score INTEGER,
        storage_used INTEGER,
        storage_total INTEGER,
        battery_level INTEGER,
        temperature REAL,
        ram_used INTEGER,
        ram_total INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> saveMetric({
    required ReapScore score,
    required int storageUsed,
    required int storageTotal,
    required int batteryLevel,
    required double temperature,
    required int ramUsed,
    required int ramTotal,
  }) async {
    final db = await database;
    await db.insert('metrics', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'score': score.score,
      'storage_used': storageUsed,
      'storage_total': storageTotal,
      'battery_level': batteryLevel,
      'temperature': temperature,
      'ram_used': ramUsed,
      'ram_total': ramTotal,
    });
  }

  Future<List<Map<String, dynamic>>> getMetrics({int days = 7}) async {
    final db = await database;
    final startTime = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    return await db.query(
      'metrics',
      where: 'timestamp >= ?',
      whereArgs: [startTime],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }
}