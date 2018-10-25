import 'dart:convert';

import 'package:amadeus/lists/SubjectList.dart';
import 'package:amadeus/response/GenericResponse.dart';

/// Created by Vitor Martins on 25/08/18.

class SubjectResponse extends GenericResponse {

  SubjectList _data;

  void fromJson(String vJson) {
    Map myJson = json.decode(vJson);
    _data = new SubjectList();
    _data.fromJson(myJson['data']);
    message = myJson['message'];
    type = myJson['type'];
    title = myJson['title'];
    success = myJson['success'];
    number = myJson['number'];
    extra = myJson['extra'];
  }

  SubjectList get data => _data;
  set data(SubjectList data) => this._data = data;
}