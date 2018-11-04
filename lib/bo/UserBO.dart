import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/response/GenericResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/response/UserResponse.dart';
import 'package:amadeus/utils/HttpUtils.dart';

/// Created by Vitor Martins on 25/08/18.

class UserBO {
  Future<UserResponse> login(BuildContext context, String host, String email, String password) async {

    String url = "$host/api/token";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => email);
    data.putIfAbsent("password", () => password);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "");

    if(json != null && json.trim().length > 0) {
      print(json);

      TokenResponse token = new TokenResponse.fromJson(json);

      if(token != null) {
        token.setData(email, password);
        token.setTimeStamp();
        token.webserverUrl = host;

        await TokenCacheController.setTokenCache(context, token);

        url = "$host/api/users/login/";

        json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

        if(json != null && json.trim().length > 0) {
          print("login - " + json);

          return UserResponse.fromJson(json);
        }
      }
    }
    return null;
  }

  Future<GenericResponse> registerDevice(BuildContext context, UserModel user, String device) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/users/register_device/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("device", () => device);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("registerDevice - " + json);

      return GenericResponse.fromJson(json);
    }
    return null;
  }

  Future<GenericResponse> logout(BuildContext context, UserModel user, String device) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/users/logout/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("device", () => device);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("Logout - " + json);

      return GenericResponse.fromJson(json);
    }
    return null;
  }
}
