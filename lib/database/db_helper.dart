import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String _databaseName = 'app_database.db';
  static const int _databaseVersion =
      3; // Incrementa la versión de la base de datos.

  static const String _productTable = 'products';
  static const String _salesTable = 'sales';
  static const String _salesDetailsTable = 'sales_details';

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    // Abre la base de datos y recrea las tablas si es necesario.
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        // Crea la tabla de productos con la columna "reminder".
        await db.execute('''
          CREATE TABLE $_productTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            image TEXT NOT NULL,
            reminder TEXT
          )
        ''');

        // Crea la tabla de ventas.
        await db.execute('''
          CREATE TABLE $_salesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            total REAL NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');

        // Crea la tabla de detalles de ventas.
        await db.execute('''
          CREATE TABLE $_salesDetailsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            FOREIGN KEY (sale_id) REFERENCES $_salesTable (id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES $_productTable (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ===================== MÉTODOS PARA VENTAS =====================

  static Future<int> insertSale(Map<String, dynamic> sale) async {
    final db = await database;
    return await db.insert(_salesTable, sale);
  }

  static Future<List<Map<String, dynamic>>> fetchSales() async {
    final db = await database;
    return await db.query(_salesTable);
  }

  static Future<int> updateSale(int id, Map<String, dynamic> sale) async {
    final db = await database;
    return await db.update(
      _salesTable,
      sale,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteSale(int id) async {
    final db = await database;
    return await db.delete(
      _salesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> insertSaleDetail(Map<String, dynamic> saleDetail) async {
    final db = await database;
    return await db.insert(_salesDetailsTable, saleDetail);
  }

  static Future<List<Map<String, dynamic>>> fetchSaleDetails(int saleId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT sd.quantity, p.name, p.price, p.image
    FROM $_salesDetailsTable sd
    INNER JOIN $_productTable p ON sd.product_id = p.id
    WHERE sd.sale_id = ?
    ''', [saleId]);
  }

  static Future<int> updateSaleStatus(int saleId, String newStatus) async {
    final db = await database;
    return await db.update(
      _salesTable,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }

  // ===================== MÉTODOS PARA PRODUCTOS =====================

  static Future<List<Map<String, dynamic>>> fetchProducts() async {
    final db = await database;
    return await db.query(_productTable);
  }

  static Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert(_productTable, product);
  }

  static Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    return await db.update(
      _productTable,
      product,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      _productTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
