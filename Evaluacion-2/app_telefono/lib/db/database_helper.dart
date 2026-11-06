import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('viajes_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favoritos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_destino TEXT NOT NULL,
        ubicacion TEXT NOT NULL
      )
    ''');
  }

  // Caso 1: Insertar destino
  Future<int> insertFavorito(Map<String, dynamic> destino) async {
    final db = await instance.database;
    return await db.insert('favoritos', destino);
  }

  // Caso 2: Consultar destinos offline
  Future<List<Map<String, dynamic>>> obtenerFavoritos() async {
    final db = await instance.database;
    return await db.query('favoritos');
  }

  // Caso 3: Eliminar destino
  Future<int> deleteFavorito(int id) async {
    final db = await instance.database;
    return await db.delete(
      'favoritos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}