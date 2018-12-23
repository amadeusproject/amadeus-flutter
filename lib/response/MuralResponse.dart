import 'dart:convert';

import 'package:amadeus/lists/MuralList.dart';
import 'package:amadeus/models/MuralModel.dart';
import 'package:amadeus/response/GenericResponse.dart';

/// Created by Vitor Martins on 29/11/18.

class MuralResponse extends GenericResponse {

  MuralList _data;
  MuralModel _newPost;

  void fromJson(String vJson) {
    Map<String, dynamic> myJson = json.decode(vJson);
    _data = new MuralList();
    if(myJson.containsKey('data')) {
      if(myJson['data'].containsKey('posts')) {
        _data.fromJson(myJson['data']['posts']);
      }
      if(myJson['data'].containsKey('new_post')) {
        _newPost = MuralModel.fromJson(myJson['data']['new_post']);
      }
    }
    message = myJson['message'];
    type = myJson['type'];
    title = myJson['title'];
    success = myJson['success'];
    number = myJson['number'];
    extra = myJson['extra'];
  }

  MuralList get data => _data;
  set data(MuralList data) => this._data = data;

  MuralModel get newPost => _newPost;
  set newPost(MuralModel newPost) => this._newPost = newPost;
}