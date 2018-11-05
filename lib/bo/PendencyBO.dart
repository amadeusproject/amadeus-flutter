import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/response/PendencyResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/HttpUtils.dart';

/// Created by Vitor Martins on 28/10/18.

class PendencyBO {
  Future<PendencyResponse> getPendencies(BuildContext context, UserModel user, SubjectModel subject) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/pendencies";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("subject_slug", () => subject.slug);

    String content = jsonEncode(data);
    print(content);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("GetPendencies - " + json);

      PendencyResponse pendencyResponse = new PendencyResponse();
      pendencyResponse.fromJson(json);

      return pendencyResponse;
    }
    return null;
  }
}