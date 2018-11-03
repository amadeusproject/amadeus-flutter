import 'dart:convert';

/// Created by Vitor Martins on 25/08/18.

class GenericResponse {

  String _message, _type, _title;
  bool _success;
  int _number, _extra;

  GenericResponse();

  GenericResponse.fromJson(String vJson) {
    Map myJson = json.decode(vJson);
    _message = myJson['message'];
    _type = myJson['type'];
    _title = myJson['title'];
    _success = myJson['success'];
    _number = myJson['number'];
    _extra = myJson['extra'];
  }

  String get message => _message;
  set message(String message) => this._message = message;

  String get type => _type;
  set type(String type) => this._type = type;

  String get title => _title;
  set title(String title) => this._title = title;

  bool get success => _success;
  set success(bool success) => this._success = success;

  int get number => _number;
  set number(int number) => this._number = number;

  int get extra => _extra;
  set extra(int extra) => this._extra = extra;
}
