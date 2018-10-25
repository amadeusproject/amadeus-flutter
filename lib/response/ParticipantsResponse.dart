import 'dart:convert';

import 'package:amadeus/lists/ParticipantsList.dart';
import 'package:amadeus/response/GenericResponse.dart';

/// Created by Vitor Martins on 25/08/18.

class ParticipantsResponse extends GenericResponse {

  ParticipantsList _data;

  void fromJson(String vJson) {
    Map myJson = json.decode(vJson);
    _data = new ParticipantsList();
    _data.fromJson(myJson['data']);
    message = myJson['message'];
    type = myJson['type'];
    title = myJson['title'];
    success = myJson['success'];
    number = myJson['number'];
    extra = myJson['extra'];
  }

  ParticipantsList get data => _data;
  set data(ParticipantsList data) => this._data = data;
}