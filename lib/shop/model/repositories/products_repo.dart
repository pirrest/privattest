import 'dart:convert';

import 'package:privat_test/core/utils/casting.dart';
import 'package:privat_test/shop/model/product.dart';
import 'package:sqflite/sqflite.dart';

/// Local product cache backed by sqflite. Every product seen online is stored
/// here, so browsing, searching and details keep working offline.
class ProductsRepo {
  static const _table = 'products';

  final DatabaseFactory _databaseFactory;
  final String _path;
  Database? _db;

  ProductsRepo(this._databaseFactory, this._path);

  Future<void> init() async {
    _db = await _databaseFactory.openDatabase(
      _path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) => db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY,
            search_text TEXT NOT NULL,
            data TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        '''),
        onDowngrade: onDatabaseDowngradeDelete,
      ),
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> upsertAll(List<Product> products) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = _database.batch();
    for (final product in products) {
      batch.insert(_table, {
        'id': product.id,
        'search_text': _searchText(product),
        'data': jsonEncode(product.toMap()),
        'cached_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<Product?> getById(int id) async {
    final rows = await _database.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  /// Returns cached products whose title, description, category, brand or tags
  /// contain [query] (case-insensitive), ordered by id.
  Future<List<Product>> queryPage({
    required String query,
    required int limit,
    required int skip,
  }) async {
    final where = _where(query);
    final rows = await _database.query(
      _table,
      where: where.clause,
      whereArgs: where.args,
      orderBy: 'id ASC',
      limit: limit,
      offset: skip,
    );
    return rows.map(_fromRow).toList();
  }

  Future<int> count(String query) async {
    final where = _where(query);
    final rows = await _database.rawQuery(
      'SELECT COUNT(*) AS c FROM $_table'
      '${where.clause == null ? '' : ' WHERE ${where.clause}'}',
      where.args,
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Database get _database {
    final db = _db;
    if (db == null) throw StateError('ProductsRepo.init() was not called');
    return db;
  }

  ({String? clause, List<Object?>? args}) _where(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return (clause: null, args: null);

    final escaped = normalized
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    return (clause: r"search_text LIKE ? ESCAPE '\'", args: ['%$escaped%']);
  }

  Product _fromRow(Map<String, Object?> row) {
    return Product.fromMap(
      cast<Map<String, dynamic>>(
        jsonDecode(cast<String>(row['data'], orElse: '{}')),
        orElse: const {},
      ),
    );
  }

  String _searchText(Product product) {
    return [
      product.title,
      product.description,
      product.category,
      product.brand ?? '',
      ...product.tags,
    ].join(' ').toLowerCase();
  }
}
