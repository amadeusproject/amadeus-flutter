import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/cache/UserCacheController.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/home_page.dart';
import 'package:amadeus/pages/login_page.dart';
import 'package:amadeus/response/TokenResponse.dart';

class SplashPage extends StatefulWidget {
  static String tag = 'splash-page';
  @override
  _SplashPageState createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  startTime() async {
    var _duration = new Duration(seconds: 1);
    return new Timer(_duration, loadUser);
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: new Center(
        child: new Image.asset(
          "images/logo.png",
          width: 50.0,
          height: 50.0,
        ),
      ),
    );
  }

  @protected
  void loadUser() async {
    if (await UserCacheController.hasUserCache(context)) {
      UserModel user = await UserCacheController.getUserCache(context);
      if (await TokenCacheController.hasTokenCache(context)) {
        TokenResponse token = await TokenCacheController.getTokenCache(context);

        if (token.isTokenExpired()) {
          token = await token.renewToken(context);
        }

        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
            settings: const RouteSettings(name: 'home-page'),
            builder: (context) => new HomePage(user: user, token: token),
          ),
        );
        return;
      }
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var initialEmail = sharedPreferences.get(LoginPageState.emailKey) ?? "";
    var initialHost = sharedPreferences.get(LoginPageState.hostKey) ?? "";
    var initialPassword = sharedPreferences.get(LoginPageState.passwordKey) ?? "";
    var rememberPassword = sharedPreferences.getBool(LoginPageState.rememberPasswordKey) ?? false;
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
    return;
  }
}
