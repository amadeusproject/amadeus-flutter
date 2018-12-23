import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/services/Storage.dart';

class UserCacheController {
  static final String _userPreferenceKey = "USER_ID_PREFERENCE_KEY";
  static final Storage storage = new Storage();

  static UserModel _model;

  static Future<UserModel> getUserCache(BuildContext context) async {
    try {
      if (_model != null) {
        return _model;
      }

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      if (sharedPreferences.toString().contains(_userPreferenceKey)) {
        String myJson = sharedPreferences.getString(_userPreferenceKey);

        if (myJson.isNotEmpty) {
          UserModel userFromJson = new UserModel.fromJson(json.decode(myJson));

          if (userFromJson != null) {
            _model = userFromJson;
            return _model;
          }
        }
      } else {
        String myJson = await storage.readUser();

        if (myJson.isNotEmpty) {
          UserModel userFromJson = new UserModel.fromJson(json.decode(myJson));

          if (userFromJson != null) {
            _model = userFromJson;
            return _model;
          }
        }
      }
    } catch (e) {
      print("getUserCache\n" + e.toString());
    }

    return null;
  }

  static Future<bool> hasUserCache(BuildContext context) async {
    try {
      if (_model != null) {
        return true;
      }

      UserModel user = await getUserCache(context);

      if (user != null) {
        return true;
      }
    } catch (e) {
      print("hasUserCache\n" + e.toString());
    }

    return false;
  }

  static Future<void> setUserCache(BuildContext context, UserModel userLogged) async {
    try {
      String myJson = json.encode(userLogged.toJson());

      SharedPreferences editor = await SharedPreferences.getInstance();

      editor.setString(_userPreferenceKey, myJson);

      storage.writeUser(myJson);

      _model = userLogged;
    } catch (e) {
      print("setUserCache\n" + e.toString());
    }
  }

  static void removeUserCache(BuildContext context) async {
    try {
      SharedPreferences editor = await SharedPreferences.getInstance();

      editor.remove(_userPreferenceKey);

      storage.writeUser("");

      _model = null;
    } catch (e) {
      print("removeUserCache\n" + e.toString());
    }
  }
}
