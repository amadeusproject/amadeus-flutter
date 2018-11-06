import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';

class Storage {

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileUserCache async {
    final path = await _localPath;
    return new File('$path/user.txt');
  }

  Future<File> writeUser(String info) async {
    final file = await _localFileUserCache;
    return file.writeAsString(info);
  }

  Future<String> readUser() async {
    try {
      final file = await _localFileUserCache;
      String info = await file.readAsString();
      return info;
    } catch (_) {
      return '';
    }
  }

  Future<File> get _localFileTokenCache async {
    final path = await _localPath;
    return new File('$path/token.txt');
  }

  Future<File> writeToken(String info) async {
    final file = await _localFileTokenCache;
    return file.writeAsString(info);
  }

  Future<String> readToken() async {
    try {
      final file = await _localFileTokenCache;
      String info = await file.readAsString();
      return info;
    } catch (_) {
      return '';
    }
  }
}