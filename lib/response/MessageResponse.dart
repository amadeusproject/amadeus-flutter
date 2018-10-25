import 'dart:convert';

import 'package:amadeus/lists/MessagesList.dart';
import 'package:amadeus/response/GenericResponse.dart';

/// Created by Vitor Martins on 24/08/18.

class MessageResponse extends GenericResponse {

  MessagesList _data;

  void fromJson(String vJson) {
    Map<String, dynamic> myJson = json.decode(vJson);
    _data = new MessagesList();
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

  MessagesList get data => _data;
  set data(MessagesList data) => this._data = data;
}
