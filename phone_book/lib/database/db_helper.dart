import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phone_book/models/Contact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database
      _db; // dart dilinde değişkenlerin başına _ konur ise private olarak tanımlanır db değişkeni veritabanı işlemlerini yapacağı için private tanımlanması iyi olur.
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    var result = await dbClient.query("Contact3", orderBy: "name");
    return result.map((data) => Contact.fromMap(data)).toList();
  }

  initDb() async {
    var dbFolder = await getDatabasesPath();

    String path = join(dbFolder, "Contact3.db");
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  Future<FutureOr<void>> _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE Contact3(id INTEGER PRIMARY KEY,name TEXT,phoneNumber TEXT,avatar TEXT)");
  }

  Future<int> InsertContact(Contact contact) async {
    var dbCilent = await db;
    return await dbCilent.insert("Contact3", contact.toMap());
  }

  Future<void> removeContact(int id) async {
    var dbClient = await db;
    return await dbClient.delete("Contact3", where: "id=?", whereArgs: [id]);
  }
}
