library custom_database;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

class CustomDatabase {
  CustomDatabase._privateContructor();

  static final CustomDatabase _instance = CustomDatabase._privateContructor();

  factory CustomDatabase() => _instance;

  String _path = "";
  Map<String, List<String>> _map = {};

  Future<void> openDatabase(String path) async {
    _path = path;
    if (!await File("$path/Base.txt").exists()) {
      await _writeFile("$path/Base.txt", "");
      //debugPrint("WITING SUCESSULL");
    } else {
      await _readMainFiles();
    }
  }

  Future<File?> _writeFile(String path, content) async {
    try {
      final File file = File(path);

      String jsonString = "";

      if (content.isNotEmpty) {
        jsonString = json.encode(content);
      }

      //debugPrint("WRITING FILE SUCESSFULL");

      return file.writeAsString(jsonString);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<String> _readFile(String path) async {
    try {
      final file = File(path);

      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      //debugPrint(e.toString());
      return "";
    }
  }

  Future<List> query(String tableName) async {
    try {
      List _tableData = [];

      String _jsonString = await _readFile("$_path/$tableName/$tableName.txt");

      if (_jsonString.isNotEmpty) {
        List<String> _fileNames = typeCastStringList(json.decode(_jsonString));

        for (var i = 0; i < _fileNames.length; i++) {
          String _fileName = _fileNames[i];

          String _jsonStringContent =
              await _readFile("$_path/$tableName/$_fileName.txt");

          // print("$_path/$tableName/$_fileName.txt");

          _tableData.add(json.decode(_jsonStringContent));
        }
      } else {
        // debugPrint("NO DATA AVAILABLE");
      }

      return _tableData;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<void> insert(
      String tableName, String primaryKey, Map<String, dynamic> values) async {
    try {
      await _createTable(tableName);
      List<String> _mainFile = [];
      if (_map.containsKey(tableName)) {
        _mainFile = _map[tableName]!;
      }

      final String fileName = primaryKey;

      values['primary_key'] = primaryKey;

      await _writeFile("$_path/$tableName/$fileName.txt", values);

      _mainFile.add(fileName);

      await _writeFile("$_path/$tableName/$tableName.txt", _mainFile);

      _map[tableName] = _mainFile;
    } catch (e) {
      //debugPrint(e.toString());
    }
  }

  Future<void> update(String tableName, String primaryKey, Map content) async {
    try {
      content['primary_key'] = primaryKey;

      await _writeFile("$_path/$tableName/$primaryKey.txt", content);
    } catch (e) {
      //debugPrint(e.toString());
    }
  }

  Future<void> delete(String tableName, String primaryKey) async {
    try {
      List<String> _mainFile = _map[tableName]!;

      await _deleteFile("$_path/$tableName/$primaryKey.txt");

      for (var item in _mainFile) {
        if (item == primaryKey) {
          _mainFile.remove(item);
          break;
        }
      }

      await _writeFile("$_path/$tableName/$tableName.txt", _mainFile);
    } catch (e) {
      //debugPrint(e.toString());
    }
  }

  Future<void> _createTable(String tableName) async {
    try {
      String _absolutePath = "$_path/$tableName";

      if (!await Directory(_absolutePath).exists()) {
        await Directory(_absolutePath).create().then((value) async {
          await File("$_absolutePath/$tableName.txt").create();
        });

        List<String> _base = _map['Base']!;

        _base.add(tableName);

        await _writeFile("$_path/Base.txt", _base);
      }
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  Future<void> _readMainFiles() async {
    try {
      String jsonString = await _readFile("$_path/Base.txt");

      _map['Base'] = [];

      if (jsonString.isNotEmpty) {
        List _baseFileNames = json.decode(jsonString);

        _map['Base'] = typeCastStringList(_baseFileNames);

        for (var i = 0; i < _baseFileNames.length; i++) {
          String _fileName = _baseFileNames[i];

          String jsonString =
              await _readFile("$_path/$_fileName/$_fileName.txt");

          if (jsonString.isNotEmpty) {
            List _decoded = json.decode(jsonString);

            _map[_fileName] = typeCastStringList(_decoded);

            // debugPrint("READING SUCESSFULL");
          } else {
            print("INSIDE");
            // debugPrint("NO DATA AVAILABLE");
          }
        }
      } else {
        // debugPrint("NO DATA AVAILABLE");
      }
    } catch (e) {
      // debugPrint(e.toString());
    }

    // print(_map);
  }

  Future<void> _deleteFile(path) async => await File(path).delete();

  List<String> typeCastStringList(List list) =>
      list.map((e) => e.toString()).toList();

  // String _getFileName(int length) {
  //   final random = Random.secure();
  //   final values = List<int>.generate(length, (i) => random.nextInt(255));
  //   return base64UrlEncode(values);
  // }
}
