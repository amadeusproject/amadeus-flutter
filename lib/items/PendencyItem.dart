import 'package:flutter/material.dart';

import 'package:amadeus/models/PendencyModel.dart';
import 'package:amadeus/localizations.dart';
import 'package:amadeus/res/colors.dart';

abstract class PendencyPageItem {}

class DateItem extends StatelessWidget implements PendencyPageItem {

  final String dateToShow;

  DateItem(this.dateToShow);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(4.0),
          color: dateBackground,
        ),
        padding: EdgeInsets.all(5.0),
        child: new Text(
          dateToShow,
          style: new TextStyle(
            color: dateFontColor,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}

class PendencyItem extends StatelessWidget implements PendencyPageItem {

  final PendencyModel _pendency;

  PendencyItem(this._pendency);

  String getText(BuildContext context) {
    int number = _pendency.pendencies;
    if(number == 1) {
      return Translations.of(context).text('pedencyNotifyMessageStart') + " ${number.toString()} " + Translations.of(context).text('pedencyNotifyMessageSingular');
    } else if(number > 1) {
      return Translations.of(context).text('pedencyNotifyMessageStart') + " ${number.toString()} " + Translations.of(context).text('pedencyNotifyMessagePlural');
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      color: myMessage,
      padding: new EdgeInsets.all(10.0),
      margin: new EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 20.0),
      child: new Text(getText(context), textAlign: TextAlign.center, style: new TextStyle(color: fontColor),),
    );
  }
}