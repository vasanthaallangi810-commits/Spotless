
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/report.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('swachhatha.db');
    return _database!;
  }

  // ============================================================
  // INITIALIZE DATABASE
  // ============================================================

  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    final db = await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );

    await _ensureReportsSchema(db);
    return db;
  }

  // ============================================================
  // CREATE TABLES
  // ============================================================

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    // USERS TABLE
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // REPORTS TABLE
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        imagePath TEXT,
        imageUrl TEXT,
        imageBytes BLOB,
        status TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> _ensureReportsSchema(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='reports'",
    );

    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          type TEXT NOT NULL,
          description TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          imagePath TEXT,
          imageUrl TEXT,
          imageBytes BLOB,
          status TEXT NOT NULL,
          date TEXT NOT NULL
        )
      ''');
      return;
    }

    final columns = await db.rawQuery(
      "PRAGMA table_info(reports)",
    );
    final columnNames = columns.map((row) => row['name'] as String).toSet();

    if (!columnNames.contains('userId')) {
      await db.execute(
        'ALTER TABLE reports ADD COLUMN userId INTEGER NOT NULL DEFAULT 0',
      );
    }

    if (!columnNames.contains('imageUrl')) {
      await db.execute(
        'ALTER TABLE reports ADD COLUMN imageUrl TEXT',
      );
    }
  }

  // ============================================================
  // DATABASE UPGRADE
  // ============================================================

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''' );
    }

    if (oldVersion < 3) {
      final existing = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='reports'",
      );
      if (existing.isEmpty) {
        await db.execute('''
          CREATE TABLE reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            type TEXT NOT NULL,
            description TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            imagePath TEXT,
            imageUrl TEXT,
            imageBytes BLOB,
            status TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      } else {
        final columns = await db.rawQuery('PRAGMA table_info(reports)');
        final names = columns.map((row) => row['name'] as String).toSet();
        if (!names.contains('userId')) {
          await db.execute(
            'ALTER TABLE reports ADD COLUMN userId INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (!names.contains('imageUrl')) {
          await db.execute(
            'ALTER TABLE reports ADD COLUMN imageUrl TEXT',
          );
        }
      }
    }

    await _ensureReportsSchema(db);
  }

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<int> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await database;

    return await db.insert(
      'users',
      {
        'name': name,
        'email': email.toLowerCase(),
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // LOGIN USER
  // ============================================================

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [
        email.toLowerCase(),
        password,
      ],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // ============================================================
  // CHECK WHETHER EMAIL ALREADY EXISTS
  // ============================================================

  Future<bool> emailExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ============================================================
  // INSERT REPORT
  // ============================================================

  Future<int> insertReport({
    required int userId,
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    String imagePath = '',
    String? imageUrl,
    Uint8List? imageBytes,
    required String status,
    required DateTime date,
  }) async {
    final db = await database;

    final data = {
      'userId': userId,
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'imageBytes': imageBytes,
      'status': status,
      'date': date.toIso8601String(),
    };

    return await db.insert(
      'reports',
      data,
    );
  }

  // ============================================================
  // GET ALL REPORTS
  // ============================================================

  Future<List<Report>> getReports({int? userId}) async {
    final db = await database;

    final result = await db.query(
      'reports',
      where: userId == null ? null : 'userId = ?',
      whereArgs: userId == null ? null : [userId],
      orderBy: 'date DESC',
    );

    debugPrint('========== REPORTS TABLE ==========');
    debugPrint('Number of rows: ${result.length}');

    for (final row in result) {
      debugPrint('');
      debugPrint('ID: ${row['id']}');
      debugPrint('Type: ${row['type']}');
      debugPrint('Description: ${row['description']}');
      debugPrint('Latitude: ${row['latitude']}');
      debugPrint('Longitude: ${row['longitude']}');
      debugPrint('Status: ${row['status']}');
      debugPrint('Date: ${row['date']}');
      debugPrint(
        'Image: ${row['imageBytes'] != null ? 'YES' : 'NO'}',
      );
    }

    debugPrint('===================================');

    return result.map((map) {
      return Report(
        type: map['type'] as String,
        description: map['description'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        imagePath: (map['imagePath'] as String?) ?? '',
        imageUrl: map['imageUrl'] as String?,
        imageBytes: map['imageBytes'] != null
            ? Uint8List.fromList(
                (map['imageBytes'] as List<int>),
              )
            : null,
        status: map['status'] as String,
        date: DateTime.parse(
          map['date'] as String,
        ),
      );
    }).toList();
  }

  // ============================================================
  // DELETE REPORT
  // ============================================================

  Future<int> deleteReport(int id) async {
    final db = await database;

    return await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> close() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}