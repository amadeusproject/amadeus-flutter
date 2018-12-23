import 'dart:convert';

import 'package:amadeus/lists/CommentList.dart';
import 'package:amadeus/models/CommentModel.dart';
import 'package:amadeus/response/GenericResponse.dart';

/// Created by Vitor Martins on 18/12/18.

class CommentResponse extends GenericResponse {

  CommentList _data;
  CommentModel _newComment;

  void fromJson(String vJson) {
    Map<String, dynamic> myJson = json.decode(vJson);
    _data = new CommentList();
    if(myJson.containsKey('data')) {
      if(myJson['data'].containsKey('comments')) {
        _data.fromJson(myJson['data']['comments']);
      }
      if(myJson['data'].containsKey('new_comment')) {
        _newComment = CommentModel.fromJson(myJson['data']['new_comment']);
      }
    }
    message = myJson['message'];
    type = myJson['type'];
    title = myJson['title'];
    success = myJson['success'];
    number = myJson['number'];
    extra = myJson['extra'];
  }

  CommentList get data => _data;
  set data(CommentList data) => this._data = data;

  CommentModel get newComment => _newComment;
  set newComment(CommentModel newComment) => this._newComment = newComment;
}