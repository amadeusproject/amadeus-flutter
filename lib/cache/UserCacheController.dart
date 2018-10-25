import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/models/UserModel.dart';

class UserCacheController {

  static final String _userPreferenceKey = "USER_ID_PREFERENCE_KEY";

  static UserModel _model;

  static Future<UserModel> getUserCache(BuildContext context) async {
    try {
      if(_model != null) {
        return _model;
      }

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      if(sharedPreferences.toString().contains(_userPreferenceKey)) {
        String myJson = sharedPreferences.getString(_userPreferenceKey);

        if(myJson.isNotEmpty) {
          UserModel userFromJson = new UserModel.fromJson(json.decode(myJson));

          if(userFromJson != null) {
            _model = userFromJson;
            return _model;
          }
        }
      }
    } catch(e) {
      print(e);
    }

    return null;
  }

  static Future<bool> hasUserCache(BuildContext context) async {
    try {
      if(_model != null) {
        return true;
      }

      UserModel user = await getUserCache(context);

      if(user != null) {
        return true;
      }
    } catch(e) {
      print(e);
    }

    return false;
  }

  static Future<void> setUserCache(BuildContext context, UserModel userLogged) async {
    try {
      String myJson = json.encode(userLogged.toJson());

      SharedPreferences editor = await SharedPreferences.getInstance();

      editor.setString(_userPreferenceKey, myJson);

      _model = userLogged;      
    } catch(e) {
      print(e);
    }
  }

  static void removeUserCache(BuildContext context) async {
    try {
      SharedPreferences editor = await SharedPreferences.getInstance();

      editor.remove(_userPreferenceKey);

      _model = null;
    } catch(e) {
      print(e);
    }
  }
}