import 'package:amadeus/widgets/Badge.dart';
import 'package:flutter/material.dart';

import 'package:amadeus/localizations.dart';
import 'package:amadeus/res/colors.dart';

class CommentBar extends StatelessWidget {
  CommentBar(this.comments);

  final int comments;

  Widget getCommentBar(BuildContext context) {
    if ((comments ?? 0) == 0) {
      return new Padding(
        padding: new EdgeInsets.symmetric(vertical: 2.0),
        child: new Text(
          Translations.of(context).text("firstToComment"),
          style: new TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      String number = comments > 9 ? "9+" : "$comments";
      return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            Translations.of(context).text("comments"),
            style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          new Badge(
            number,
            size: 16.0,
            fontSize: 8.0,
            padding: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      child: new Container(
        padding: new EdgeInsets.symmetric(vertical: 2.0),
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          color: muralCommentsBackground,
        ),
        child: getCommentBar(context),
      ),
    );
  }
}
