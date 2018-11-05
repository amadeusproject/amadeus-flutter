import 'dart:convert';

import 'package:amadeus/lists/PendenciesList.dart';
import 'package:amadeus/response/GenericResponse.dart';

/// Created by Vitor Martins on 28/10/18.

class PendencyResponse extends GenericResponse {

  PendenciesList _data;

  void fromJson(String vJson) {
    Map<String, dynamic> myJson = json.decode(vJson);
    _data = new PendenciesList();
    if(myJson.containsKey('data')) {
      _data.fromJson(myJson['data']);
    }
    message = myJson['message'];
    type = myJson['type'];
    title = myJson['title'];
    success = myJson['success'];
    number = myJson['number'];
    extra = myJson['extra'];
  }

  PendenciesList get data => _data;
  set data(PendenciesList data) => this._data = data;
}
