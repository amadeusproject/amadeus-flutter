import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/bo/UserBO.dart';
import 'package:amadeus/cache/CacheController.dart';
import 'package:amadeus/cache/UserCacheController.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/login_page.dart';

class Logout {
  static void goLogin(BuildContext context) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    String token = await _firebaseMessaging.getToken();
    UserModel user = await UserCacheController.getUserCache(context);

    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.remove("USER_ID_KEY_TOKEN");

    CacheController.clearCache(context);

    if(user != null && token != null) {
      await UserBO().logout(context, user, token);
    }

    var initialEmail = _sharedPreferences.get(LoginPageState.emailKey) ?? "";
    var initialHost = _sharedPreferences.get(LoginPageState.hostKey) ?? "";
    var initialPassword = _sharedPreferences.get(LoginPageState.passwordKey) ?? "";
    var rememberPassword = _sharedPreferences.getBool(LoginPageState.rememberPasswordKey) ?? false;
    Navigator.of(context).pushReplacement(
      new MaterialPageRoute(
        settings: const RouteSettings(name: 'login-page'),
        builder: (context) => new LoginPage(
          initialHost: initialHost,
          initialEmail: initialEmail,
          initialPassword: initialPassword,
          rememberPassword: rememberPassword,
        ),
      )
    );
  }
}