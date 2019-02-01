import 'dart:async';

import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:amadeus/localizations.dart';

class DateUtils {
  static String currentDate() {
    return DateTime.now().toUtc().toString().replaceAll(' ', 'T');
  }

  static DateTime convertTimezone(DateTime date) {
    String tz = DateTime.now().timeZoneName;
    if (tz == "GMT") return date;
    if (tz == "BRST") return date.add(new Duration(hours: -2));
    if (tz == "BRT") return date.add(new Duration(hours: -3));
    if (tz == "EST") return date.add(new Duration(hours: -5));
    if (tz == "PST") return date.add(new Duration(hours: -8));
    try {
      int offset = tz != null ? int.parse(tz) : 0;
      return date.add(new Duration(hours: offset));
    } catch (e) {
      print(e);
      return date;
    }
  }

  static DateTime toDateTime(String date) {
    DateTime dateTime = DateTime.parse(date.replaceAll('T', ' '));
    dateTime = DateUtils.convertTimezone(dateTime);
    return dateTime;
  }

  static String getHour(String date) {
    try {
      DateTime newDate = DateTime.parse(date.replaceAll('T', ' '));
      newDate = DateUtils.convertTimezone(newDate);
      String result = "";
      if (newDate.hour < 10) {
        result += '0';
      }
      result += "${newDate.hour}:";
      if (newDate.minute < 10) {
        result += '0';
      }
      result += "${newDate.minute}";
      return result;
    } catch (e) {
      print("getHour\n" + e.toString());
    }
    return null;
  }

  static Future<String> displayDate(BuildContext context, String newDate) async {
    try {
      DateTime _newDate = DateTime.parse(newDate.replaceAll('T', ' '));
      _newDate = DateUtils.convertTimezone(_newDate);
      DateTime _today = DateTime.now();
      DateTime _yesterday = _today.subtract(new Duration(days: 1));

      if (compareOnlyDate(_newDate, _today)) {
        return Translations.of(context).text('today').toUpperCase();
      } else if (compareOnlyDate(_newDate, _yesterday)) {
        return Translations.of(context).text('yesterday').toUpperCase();
      } else {
        Locale myLocale = Localizations.localeOf(context);
        String locale =
            myLocale.languageCode == "pt-BR" ? "pt_BR" : myLocale.languageCode;
        await initializeDateFormatting(locale, null);
        return DateFormat.yMMMMd(locale).format(_newDate).toUpperCase();
      }
    } catch (e) {
      print("displayDate\n" + e.toString());
    }
    return "";
  }

  static bool compareOnlyDate(DateTime fstDate, DateTime sndDate) {
    return fstDate.day == sndDate.day &&
        fstDate.month == sndDate.month &&
        fstDate.year == sndDate.year;
  }

  static Future<String> displayPendencyDate(BuildContext context, String date) async {
    try {
      List<String> dates = date.split('-');
      DateTime _newDate = new DateTime(
          int.parse(dates[0]), int.parse(dates[1]), int.parse(dates[2]));
      DateTime _today = DateTime.now();
      DateTime _yesterday = _today.subtract(new Duration(days: 1));

      if (compareOnlyDate(_newDate, _today)) {
        return Translations.of(context).text('today').toUpperCase();
      } else if (compareOnlyDate(_newDate, _yesterday)) {
        return Translations.of(context).text('yesterday').toUpperCase();
      } else {
        Locale myLocale = Localizations.localeOf(context);
        String locale =
            myLocale.languageCode == "pt-BR" ? "pt_BR" : myLocale.languageCode;
        await initializeDateFormatting(locale, null);
        return DateFormat.yMMMMd(locale).format(_newDate).toUpperCase();
      }
    } catch (e) {
      print("displayPendencyDate\n" + e.toString());
    }
    return "";
  }
}
