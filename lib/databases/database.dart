import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

const personTable = "Persons";
const orderTable = "Orders";
const commentTable = "Comments";
const productTable = "Products";
const productTypeTable = "ProductTypes";

class DatabaseInstance {
  static final DatabaseInstance databaseInstance = DatabaseInstance();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _createDatabase();
      return _database!;
    }
  }

  _createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = "${documentsDirectory.path}boh.db";

    return await openDatabase(path,
        version: 1, onCreate: _initDb, password: "123456");
  }

  _initDb(Database database, int version) async {
    await database.execute("create table $personTable ("
        "id integer primary key, "
        "first_name text not null, "
        "last_name text not null, "
        "blocked integer not null"
        ")");
    await database.execute("create table $orderTable ("
        "id integer primary key, "
        "person_id integer not null, "
        "comment_id integer, "
        "order_date text not null, "
        "foreign key(comment_id) references $commentTable(id), "
        "foreign key(person_id) references $personTable(id)"
        ")");
    await database.execute("create table $commentTable ("
        "id integer primary key, "
        "content text not null, "
        "done integer not null, "
        "order_id integer not null, "
        "foreign key(order_id) references $orderTable(id)"
        ")");
    await database.execute("create table $productTable ("
        "id integer primary key, "
        "order_id integer not null, "
        "product_type_id integer not null, "
        "status text not null, "
        "received_date text, "
        "foreign key(product_type_id) references $productTypeTable(id), "
        "foreign key(order_id) references $orderTable(id)"
        ")");
    await database.execute("create table $productTypeTable ("
        "id integer primary key, "
        "name text not null, "
        "material_icon_identifier text not null"
        ")");
  }
}