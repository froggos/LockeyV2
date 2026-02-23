import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lockey_app/models/password.dart';
import 'package:lockey_app/services/encryption.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:lockey_app/models/category.dart' as LockeyCategory;

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'lockey.db';
  static const int _dbVersion = 1;
  static const _storage = FlutterSecureStorage();
  static const _dbPasswordKey = 'database_password';

  static const String tablePasswords = 'passwords';
  static const String tableCategories = 'categories';

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<String> _getDatabasePassword() async {
    String? password = await _storage.read(key: _dbPasswordKey);

    if (password == null) {
      password = DateTime.now().millisecondsSinceEpoch.toString() +
          Platform.localHostname;

      await _storage.write(key: _dbPasswordKey, value: password);
    }

    return password;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    final password = await _getDatabasePassword();

    return await openDatabase(
      path,
      version: _dbVersion,
      password: password,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategories (
        id TEXT PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        colorCode INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePasswords (
        id TEXT PRIMARY KEY AUTOINCREMENT,
        accountName TEXT NOT NULL,
        password TEXT NOT NULL,
        site TEXT,
        categoryId TEXT,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES $tableCategories (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_passwords_accountName ON $tablePasswords(accountName)
    ''');

    await db.execute('''
      CREATE INDEX idx_passwords_categoryId ON $tablePasswords(categoryId)
    ''');

    await db.insert(tableCategories, {
      'name': 'Sin categoría',
      'colorCode': 0xFFB53C3C,
    });

    await db.insert(tableCategories, {
      'name': 'Sin categoría',
      'colorCode': 0xFFB53C3C,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<List<Password>> getPasswords() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
      p.id,
      p.accountName,
      p.password,
      p.site,
      p.categoryId,
      c.id as cat_id,
      c.name as cat_name,
      c.colorCode as cat_colorCode,
      FROM $tablePasswords p
      LEFT JOIN $tableCategories c ON p.categoryId = c.id
      ORDER BY p.createdAt DESC
    ''');

    final List<Password> passwords = [];

    for (var map in maps) {
      final encryptedPassword = map['password'] as String;
      final decryptedPassword =
          await EncryptionService.decrypt(encryptedPassword);

      LockeyCategory.Category? category;
      if (map['categoryId'] != null) {
        category = LockeyCategory.Category(
          id: map['cat_id'],
          name: map['cat_name'],
          colorCode: map['cat_colorCode'],
        );
      }

      passwords.add(Password(
        id: map['id'],
        accountName: map['accountName'],
        password: decryptedPassword,
        site: map['site'],
        category: category,
      ));
    }

    return passwords;
  }

  Future<int> savePassword(Password password) async {
    final db = await database;

    final encryptedPassword = await EncryptionService.encrypt(password.password);

    final id = await db.insert(
      tablePasswords,
      {
        'accountName': password.accountName,
        'password': encryptedPassword,
        'site': password.site,
        'categoryId': password.category?.id,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<void> deletePassword(Password password) async {
    final db = await database;

    await db.delete(
      tablePasswords,
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  Future<List<LockeyCategory.Category>> getCategories() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableCategories, orderBy: 'name ASC',);

    return maps.map((map) => LockeyCategory.Category.fromJson(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // SOLO PARA TESTING
  // Future<void> deleteDatabase() async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, _dbName);
  //
  //   if (_database != null) {
  //     await _database!.close();
  //     _database = null;
  //   }
  //
  //   final file = File(path);
  //   if (await file.exists()) {
  //     await file.delete();
  //   }
  //
  //   await _storage.delete(key: _dbPasswordKey);
  // }
}
