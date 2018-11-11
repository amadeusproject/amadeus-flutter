import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/response/ParticipantsResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/HttpUtils.dart';

/// Created by Vitor Martins on 25/08/18.

class ParticipantsBO {
  Future<ParticipantsResponse> getParticipants(BuildContext context, UserModel user, String subjectSlug) async {

    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/participants/get_participants/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("subject_slug", () => subjectSlug);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("GetParticipants - $json");

      ParticipantsResponse participantsResponse = new ParticipantsResponse();
      participantsResponse.fromJson(json);

      return participantsResponse;
    }
    return null;
  }
}
