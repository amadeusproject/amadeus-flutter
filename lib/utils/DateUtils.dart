import 'package:flutter/material.dart';

import 'package:amadeus/localizations.dart';

class DateUtils {
  static String currentDate() {
    return DateTime.now().toUtc().toString().replaceAll(' ', 'T');
  }

  static String toStr(DateTime date) {
    return date.toUtc().toString().replaceAll(' ', 'T');
  }

  static DateTime toDateTime(String date) {
    return DateTime.parse(date.replaceAll('T', ' '));
  }

  static String getHour(String date) {
    try{
      DateTime newDate = DateTime.parse(date.replaceAll('T', ' '));
      String result = "";
      if(newDate.hour < 10) {
        result += '0';
      }
      result += "${newDate.hour}:";
      if(newDate.minute < 10) {
        result += '0';
      }
      result += "${newDate.minute}";
      return result;
    } catch(e) {
      print(e);
    }
    return null;
  }

  static String displayDate(BuildContext context, String newDate) {
    try {
      DateTime _newDate = DateTime.parse(newDate.replaceAll('T', ' '));
      DateTime _today = DateTime.now();
      DateTime _yesterday = _today.subtract(new Duration(days: 1));

      if(compareOnlyDate(_newDate, _today)) {
        return Translations.of(context).text('today');
      } else if(compareOnlyDate(_newDate, _yesterday)) {
        return Translations.of(context).text('yesterday');
      } else {
        return "${_newDate.day}/${_newDate.month}/${_newDate.year}";
      }
    } catch(e) {
      print(e);
    }
    return "";
  }

  static bool compareOnlyDate(DateTime fstDate, DateTime sndDate) {
    return fstDate.day == sndDate.day && fstDate.month == sndDate.month && fstDate.year == sndDate.year;
  }
}