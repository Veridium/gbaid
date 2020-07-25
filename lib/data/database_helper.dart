import 'dart:async';
 
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'model/credential.dart';
 
class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
 
  factory DatabaseHelper() => _instance;
 
  final String tableCreds = 'credentialTable';
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnDescription = 'description';
  final String columnIcon = 'icon';
 
  static Database _db;
 
  DatabaseHelper.internal();
 
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
 
    return _db;
  }
 
  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'credentials.db');
 
//    await deleteDatabase(path); // just for testing
 
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }
 
  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableCreds($columnId INTEGER PRIMARY KEY, $columnTitle TEXT, $columnDescription TEXT, $columnIcon TEXT)');
  }
 
  Future<int> saveCred(Credential cred) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableCreds, cred.toMap());
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableCreds ($columnTitle, $columnDescription, $columnIcon) VALUES (\'${cred.title}\', \'${cred.description}\')');
 
    return result;
  }
 
  Future<List> getAllCreds() async {
    var dbClient = await db;
    var result = await dbClient.query(tableCreds, columns: [columnId, columnTitle, columnDescription, columnIcon]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableCreds');
 
    return result.toList();
  }
 
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $tableCreds'));
  }
 
  Future<Credential> getCred(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tableCreds,
        columns: [columnId, columnTitle, columnDescription, columnIcon],
        where: '$columnId = ?',
        whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableCreds WHERE $columnId = $id');
 
    if (result.length > 0) {
      return new Credential.fromMap(result.first);
    }
 
    return null;
  }
 
  Future<int> deleteCred(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableCreds, where: '$columnId = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableCreds WHERE $columnId = $id');
  }
 
  Future<int> updateCred(Credential cred) async {
    var dbClient = await db;
    return await dbClient.update(tableCreds, cred.toMap(), where: "$columnId = ?", whereArgs: [cred.id]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableCreds SET $columnTitle = \'${cred.title}\', $columnDescription = \'${cred.description}\', $columnIcon = \'${cred.icon}\' WHERE $columnId = ${cred.id}');
  }
 
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}