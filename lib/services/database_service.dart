import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/credential.dart';
import 'encryption_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  factory DatabaseService() => _instance;
  DatabaseService._();

  Database? _db;
  final _crypto = EncryptionService();

  static const _encryptedFields = [
    'username',
    'email',
    'password',
    'url',
    'api_key',
    'notes'
  ];

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wault_secure.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE credentials (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT DEFAULT 'General',
            username TEXT,
            email TEXT,
            password TEXT,
            url TEXT,
            api_key TEXT,
            notes TEXT,
            is_favorite INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Map<String, dynamic> _encryptRow(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);
    for (final field in _encryptedFields) {
      final val = result[field];
      if (val != null && val.toString().isNotEmpty) {
        result[field] = _crypto.encrypt(val.toString());
      }
    }
    return result;
  }

  Map<String, dynamic> _decryptRow(Map<String, dynamic> data) {
    final result = Map<String, dynamic>.from(data);
    for (final field in _encryptedFields) {
      final val = result[field];
      if (val != null && val.toString().isNotEmpty) {
        result[field] = _crypto.decrypt(val.toString()) ?? '';
      }
    }
    return result;
  }

  Future<List<Credential>> getCredentials({
    String? search,
    String? category,
    bool favoritesOnly = false,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    if (category != null && category.isNotEmpty) {
      where.add('category = ?');
      args.add(category);
    }
    if (favoritesOnly) {
      where.add('is_favorite = 1');
    }

    final rows = await db.query(
      'credentials',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'created_at DESC',
    );

    var credentials =
        rows.map((row) => Credential.fromMap(_decryptRow(row))).toList();

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      credentials = credentials
          .where((c) =>
              c.title.toLowerCase().contains(q) ||
              (c.username?.toLowerCase().contains(q) ?? false) ||
              (c.email?.toLowerCase().contains(q) ?? false) ||
              (c.url?.toLowerCase().contains(q) ?? false) ||
              (c.notes?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return credentials;
  }

  Future<int> insertCredential(Credential cred) async {
    final db = await database;
    final data = _encryptRow(cred.toMap());
    data.remove('id');
    return db.insert('credentials', data);
  }

  Future<void> updateCredential(Credential cred) async {
    final db = await database;
    final data = _encryptRow(cred.toMap());
    await db.update('credentials', data,
        where: 'id = ?', whereArgs: [cred.id]);
  }

  Future<void> deleteCredential(int id) async {
    final db = await database;
    await db.delete('credentials', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'credentials',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final rows = await db.rawQuery(
        'SELECT DISTINCT category FROM credentials ORDER BY category');
    return rows.map((r) => r['category'] as String).toList();
  }
}
