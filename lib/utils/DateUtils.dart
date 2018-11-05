import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

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

  static Future<String> displayDate(BuildContext context, String newDate) async {
    try {
      DateTime _newDate = DateTime.parse(newDate.replaceAll('T', ' '));
      DateTime _today = DateTime.now();
      DateTime _yesterday = _today.subtract(new Duration(days: 1));

      if(compareOnlyDate(_newDate, _today)) {
        return Translations.of(context).text('today').toUpperCase();
      } else if(compareOnlyDate(_newDate, _yesterday)) {
        return Translations.of(context).text('yesterday').toUpperCase();
      } else {
        Locale myLocale = Localizations.localeOf(context);
        String locale = myLocale.languageCode == "pt-BR" ? "pt_BR" : myLocale.languageCode;
        await initializeDateFormatting(locale, null);
        return DateFormat.yMMMMd(locale).format(_newDate).toUpperCase();
      }
    } catch(e) {
      print(e);
    }
    return "";
  }

  static bool compareOnlyDate(DateTime fstDate, DateTime sndDate) {
    return fstDate.day == sndDate.day && fstDate.month == sndDate.month && fstDate.year == sndDate.year;
  }

  static Future<String> displayPendencyDate(BuildContext context, String date) async {
    try {
      var dates = date.split('-');
      DateTime _newDate = new DateTime(int.parse(dates[0]), int.parse(dates[1]), int.parse(dates[2]));
      DateTime _today = DateTime.now();
      DateTime _yesterday = _today.subtract(new Duration(days: 1));

      if(compareOnlyDate(_newDate, _today)) {
        return Translations.of(context).text('today').toUpperCase();
      } else if(compareOnlyDate(_newDate, _yesterday)) {
        return Translations.of(context).text('yesterday').toUpperCase();
      } else {
        Locale myLocale = Localizations.localeOf(context);
        String locale = myLocale.languageCode == "pt-BR" ? "pt_BR" : myLocale.languageCode;
        await initializeDateFormatting(locale, null);
        return DateFormat.yMMMMd(locale).format(_newDate).toUpperCase();
      }
    } catch(e) {
      print(e);
    }
    return "";
  }
}