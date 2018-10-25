import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:amadeus/bo/UserBO.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/cache/UserCacheController.dart';
import 'package:amadeus/response/GenericResponse.dart';
import 'package:amadeus/response/UserResponse.dart';
import 'package:amadeus/utils/DialogUtils.dart';
import 'package:amadeus/utils/LogoutUtils.dart';

/// Created by Vitor Martins on 24/08/18.

class TokenResponse extends GenericResponse {

  String _tokenType, _refreshToken, _accessToken, _scope, _webserverUrl, _email, _password;
  int _expiresIn, _timeStamp;

  TokenResponse.fromJson(String vJson) : super.fromJson(vJson) {
    Map<String, dynamic> jsonMap = json.decode(vJson);
    _tokenType = jsonMap['token_type'];
    _refreshToken = jsonMap['refresh_token'];
    _accessToken = jsonMap['access_token'];
    _scope = jsonMap['scope'];
    _expiresIn = jsonMap['expires_in'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'token_type': _tokenType,
    'refresh_token': _refreshToken,
    'access_token': _accessToken,
    'scope': _scope,
    'webserver_url': _webserverUrl,
    'email': _email,
    'password': _password,
    'expires_in': _expiresIn.toString(),
    'time_stamp': _timeStamp.toString(),
  };

  String get tokenType => _tokenType;
  set tokenType(String tokenType) => this._tokenType = tokenType;

  String get refreshToken => _refreshToken;
  set refreshToken(String refreshToken) => this._refreshToken = refreshToken;

  String get accessToken => _accessToken;
  set accessToken(String accessToken) => this._accessToken = accessToken;

  String get scope => _scope;
  set scope(String scope) => this._scope = scope;

  String get webserverUrl => _webserverUrl;
  set webserverUrl(String webserverUrl) => this._webserverUrl = webserverUrl;

  String get email => _email;
  set email(String email) => this._email = email;

  String get password => _password;
  set password(String password) => this._password = password;

  int get expiresIn => _expiresIn;
  set expiresIn(int expiresIn) => this._expiresIn = expiresIn;

  int get timeStamp => _timeStamp;
  setTimeStamp() => this._timeStamp = DateTime.now().millisecondsSinceEpoch;

  setData(String email, String password) {
    this._email = email;
    this._password = password;
  }

  bool isTokenExpired() {
    return (DateTime.now().millisecondsSinceEpoch - _timeStamp)/1000 >= _expiresIn - 1800;
    /// 1800 will work like a tolerance, allowing token to be renovate before it's expire, reducing chances of some error.
    /// You can change this value anytime. Actually it's 5% of the time of a token.
  }

  Future<TokenResponse> renewToken(BuildContext context) async {
    try {
      UserResponse userResponse = await UserBO().login(context, _webserverUrl, _email, _password);
      if(userResponse != null) {
        if(userResponse.success && userResponse.number == 1) {
          UserCacheController.setUserCache(context, userResponse.data);
          TokenResponse token = await TokenCacheController.getTokenCache(context);
          return token;
        } else if (userResponse.title != null && userResponse.title.isNotEmpty && userResponse.message != null && userResponse.message.isNotEmpty) {
          DialogUtils.dialog(context, title: userResponse.title, message: userResponse.message);
          Logout.goLogin(context);
          return null;
        } else {
          DialogUtils.dialog(context);
          Logout.goLogin(context);
          return null;
        }
      } else {
        DialogUtils.dialog(context);
        Logout.goLogin(context);
        return null;
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      Logout.goLogin(context);
      return null;
    }
  }
}
