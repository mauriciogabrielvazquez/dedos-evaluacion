import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pasajero.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('travelapp_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // CASO 4: Se cambia la versión de la BD a 2 para ejecutar la migración
    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Maneja la actualización estructural
    );
  }

  Future _createDB(Database db, int version) async {
    // Creación de la tabla con todos los campos, incluyendo el nuevo (correo)
    await db.execute('''
      CREATE TABLE pasajeros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        edad INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        correo TEXT NOT NULL
      )
    ''');
  }

  // CASO 4: Modificación de la base de datos (Evolución estructural)
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE pasajeros ADD COLUMN correo TEXT NOT NULL DEFAULT ""');
    }
  }

  // CASO 1: Insertar pasajeros
  Future<int> insertPasajero(Pasajero pasajero) async {
    final db = await instance.database;
    return await db.insert('pasajeros', pasajero.toMap());
  }

  // CASO 2: Consultar (Equivalente a dao.obtenerTodos())
  Future<List<Pasajero>> obtenerTodos() async {
    final db = await instance.database;
    final result = await db.query('pasajeros');
    return result.map((json) => Pasajero.fromMap(json)).toList();
  }

  // CASO 3: Actualizar información (Modificar el tipo/carrera)
  Future<int> actualizarTipoPasajero(int id, String nuevoTipo) async {
    final db = await instance.database;
    return await db.update(
      'pasajeros',
      {'tipo': nuevoTipo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}