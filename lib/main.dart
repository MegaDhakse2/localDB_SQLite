import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

void main() async {
  // runApp(const Sqlite());
  WidgetsFlutterBinding.ensureInitialized();               //No clarity
  final database = openDatabase(
    join(await getDatabasesPath(), 'doggie_database.db'),  //No clarity
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    },
    version: 1,
  );

  Future<void> insertDog(Dog dog) async {
    final db = await database;
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dog>> dogs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('dogs');
    return List.generate(maps.length, (index) {
      return Dog(
          id: maps[index]['id'],
          name: maps[index]['name'],
          age: maps[index]['age']);
    });
  }

  Future<void> updateDog(Dog dog) async {
    final db = await database;

    await db.update(
      'dogs',
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

  Future<void> deleteDog(int id) async {
    final db = await database;

    db.delete('dogs', where: 'id=?', whereArgs: [id]);
  }

  var fido = const Dog(
    id: 1,
    name: 'mega',
    age: 22,
  );

  await insertDog(fido);

  print('this is first inserted data ${await dogs()}');

  fido = Dog(
      id: fido.id,
      name: '${fido.name}bhi',
      age: fido.age +2,
  );
  await updateDog(fido);
  print('this is updated data ${ await dogs()}');

  await deleteDog(fido.id);
  print('after deleting ${ await dogs()}');
}

class Dog {
  final int id;
  final String name;
  final int age;

  const Dog({required this.id, required this.name, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  @override
  String toString() {
    return 'Dog{ id: $id, name: $name, age: $age}';
  }
}

// class Sqlite extends StatefulWidget {
//   const Sqlite({Key? key}) : super(key: key);
//
//   @override
//   State<Sqlite> createState() => _SqliteState();
// }
//
// class _SqliteState extends State<Sqlite> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
