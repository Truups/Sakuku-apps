import "package:sakuku/models/transaction_model.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";
import "package:flutter/foundation.dart";

class TransactionRepository {
  // Simpan Future-nya (bukan hasilnya) supaya beberapa halaman yang meminta
  // database secara bersamaan tetap memakai satu proses buka yang sama.
  static Future<Database>? _databaseFuture;
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Future<Database> _getDatabase(){
    return _databaseFuture ??= _openDatabase();
  }

  static Future<Database> _openDatabase() async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'transaction_apps.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async{
        await db.execute(
          '''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL CHECK (type IN('pemasukan', 'pengeluaran')),
            category TEXT,
            amount REAL,
            notes TEXT,
            created_at TEXT,
            updated_at TEXT
          )
          ''',
        );
        // seeding
        // final dateNow = DateTime.now().toIso8601String();
        // await db.insert('transactions',{
        //   'type': 'pemasukan',
        //   'category': 'Gaji',
        //   'amount': 6500000.0,
        //   'notes': "Gaji bulanan",
        //   'created_at': dateNow,
        //   'updated_at': null
        // });
      }
    );
  }

  static Future<List<TransactionModel>> getListTransactions({String? type, DateTime? start, DateTime? end}) async{
    final db = await _getDatabase();
    final where = <String>[];
    final args = <Object>[];

    // Cek filter type
    if(type != null){
      where.add('type = ?');
      args.add(type);
    }

    // Filter periode
    if(start != null && end != null){
      where.add('created_at >= ? AND created_at < ?');
      args.add(start.toIso8601String());
      args.add(end.toIso8601String());
    }

    final result = await db.query(
        'transactions',
        where: where.isEmpty ? null : where.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'created_at DESC, id DESC'
    );
    return result
          .map((json) => TransactionModel.fromMap(json))
          .toList();
  }

  static Future<int> addTransactions(TransactionModel transaction) async{
    final db = await _getDatabase();
    final insertData = await db.insert('transactions', transaction.toMap());
    revision.value++;
    return insertData;
  }

  static Future<int> deleteTransactions(int id) async{
    final db = await _getDatabase();
    final deleteData =  await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id]
    );
    revision.value++;
    return deleteData;
  }
}