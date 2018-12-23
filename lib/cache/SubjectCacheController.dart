import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:amadeus/lists/SubjectList.dart';
import 'package:amadeus/response/SubjectResponse.dart';

/// Created by Vitor Martins on 25/08/2018.

class SubjectCacheController {
  static final String _subjectPreferenceKey = "SUBJECT_PREFERENCES_KEY";

  static SubjectList _model;

  static Future<SubjectList> getSubjectCache(BuildContext context) async {
    try {
      if (_model != null) {
        return _model;
      }

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      if (sharedPreferences.toString().contains(_subjectPreferenceKey)) {
        String myJson = sharedPreferences.getString(_subjectPreferenceKey);

        if (myJson.isNotEmpty) {
          SubjectResponse subjectResponse = new SubjectResponse();
          subjectResponse.fromJson(json.decode(myJson));

          SubjectList subjectList = subjectResponse.data;

          if (subjectList != null) {
            _model = subjectList;
            return _model;
          }
        }
      }
    } catch (e) {
      print("getSubjectCache\n" + e.toString());
    }

    return null;
  }

  static Future<bool> hasSubjectCache(BuildContext context) async {
    try {
      if (_model != null) {
        return true;
      }

      SubjectList subjects = await getSubjectCache(context);

      if (subjects != null) {
        return true;
      }
    } catch (e) {
      print("hasSubjectCache\n" + e.toString());
    }

    return false;
  }

  static Future<void> setSubjectCache(BuildContext context, SubjectList subjects) async {
    try {
      String myJson = json.encode(subjects.toJson());

      SharedPreferences editor = await SharedPreferences.getInstance();

      editor.setString(_subjectPreferenceKey, myJson);

      _model = subjects;
    } catch (e) {
      print("setSubjectCache\n" + e.toString());
    }
  }

  static void removeSubjectCache(BuildContext context) async {
    try {
      SharedPreferences editor = await SharedPreferences.getInstance();

      editor.remove(_subjectPreferenceKey);

      _model = null;
    } catch (e) {
      print("removeSubjectCache\n" + e.toString());
    }
  }
}
