import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/bo/UserBO.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/response/GenericResponse.dart';
import 'package:amadeus/utils/DialogUtils.dart';

class InstanceIDService {

  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  static final String userIdKeyToken = "USER_ID_KEY_TOKEN";

  Future<void> sendRegistrationServer(BuildContext context, UserModel user, String token) async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

    String id = _sharedPreferences.getString(userIdKeyToken);

    if(id == null || id.isEmpty || (user != null && id != user.email)) {
      try {
        GenericResponse genericResponse = await UserBO().registerDevice(context, user, token);

        if(genericResponse != null) {
          if(genericResponse.success && genericResponse.number == 1) {
            _sharedPreferences.setString(userIdKeyToken, user.email);
          } else if(genericResponse.title != null && genericResponse.title.isNotEmpty && genericResponse.message != null && genericResponse.message.isNotEmpty) {
            DialogUtils.dialog(context, title: genericResponse.title, message: genericResponse.message);
          } else {
            DialogUtils.dialog(context);
          }
        } else {
          DialogUtils.dialog(context);
        }
      } catch (e) {
        DialogUtils.dialog(context, erro: e.toString());
        print(e);
      }
    }
  }
}
