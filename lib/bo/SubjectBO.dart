import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/response/SubjectResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/HttpUtils.dart';

/// Created by Vitor Martins on 25/08/18.

class SubjectBO {
  Future<SubjectResponse> getSubjects(BuildContext context, UserModel user) async {

    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/subjects/get_subjects/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => user.email);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print(json);

      SubjectResponse subjectResponse = new SubjectResponse();
      subjectResponse.fromJson(json);

      return subjectResponse;
    }
    return null;
  }
}
