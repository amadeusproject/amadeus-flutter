import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/cache/CacheController.dart';
import 'package:amadeus/pages/login_page.dart';

class Logout {
  static void goLogin(BuildContext context) async {
    /// TODO - Unregister device
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.remove("USER_ID_KEY_TOKEN");

    CacheController.clearCache(context);

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