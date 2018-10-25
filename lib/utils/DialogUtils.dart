import 'dart:async';

import 'package:flutter/material.dart';

import 'package:amadeus/localizations.dart';

class DialogUtils {
  static Future<Null> dialog(BuildContext context, {String title, String message, String erro}) async {
    title = title == null ? Translations.of(context).text('errorBoxTitle') : title;
    message = message == null ? Translations.of(context).text('errorBoxMsg') : message;
    message = erro == null ? message : "$message\n$erro";

    return showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK", style: new TextStyle(color: Colors.black),),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      }
    );
  }
}