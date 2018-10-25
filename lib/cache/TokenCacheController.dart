import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/response/TokenResponse.dart';

/// Created by Vitor Martins on 24/08/18.

class TokenCacheController {
  
  static final String _tokenPreferenceKey = "TOKEN_PREFERENCE_KEY";

  static TokenResponse _model;

  static Future<TokenResponse> getTokenCache(BuildContext context) async {
    try {
      if (_model != null) {
        return _model;
      }
      
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      if(sharedPreferences.toString().contains(_tokenPreferenceKey)) {
        String myJson = sharedPreferences.getString(_tokenPreferenceKey);

        if(myJson.isNotEmpty) {
          TokenResponse tokenFromJson = TokenResponse.fromJson(myJson);

          if(tokenFromJson != null) {
            _model = tokenFromJson;
            return _model;
          }
        }
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  static Future<bool> hasTokenCache(BuildContext context) async {
    try {
      if (_model != null) {
        return true;
      }

      TokenResponse token = await getTokenCache(context);

      if(token != null) {
        return true;
      }
    } catch(e) {
      print(e);
    }

    return false;
  }

  static Future<void> setTokenCache(BuildContext context, TokenResponse token) async {
    try {
      String myJson = json.encode(token.toJson());

      SharedPreferences editor = await SharedPreferences.getInstance();

      editor.setString(_tokenPreferenceKey, myJson);

      _model = token;
    } catch(e) {
      print(e);
    }
  }

  static Future<void> removeTokenCache(BuildContext context) async {
    try {
      SharedPreferences editor = await SharedPreferences.getInstance();

      editor.remove(_tokenPreferenceKey);
      
      _model = null;
    } catch(e) {
      print(e);
    }
  }
}