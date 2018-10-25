import 'dart:convert';

import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/response/GenericResponse.dart';

/// Created by Vitor Martins on 25/08/18.

class UserResponse extends GenericResponse {

  UserModel _data;

  UserResponse.fromJson(String vJson) : super.fromJson(vJson) {
    Map myJson = json.decode(vJson);
    _data = UserModel.fromJson(myJson['data']);
    message = myJson['message'];
    type = myJson['type'];
    title = myJson['title'];
    success = myJson['success'];
    number = myJson['number'];
    extra = myJson['extra'];
  }

  UserModel get data => _data;
  set data(UserModel data) => this._data = data;
}