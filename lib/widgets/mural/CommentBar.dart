import 'package:flutter/material.dart';

import 'package:amadeus/localizations.dart';
import 'package:amadeus/res/colors.dart';

class CommentBar extends StatelessWidget {
  CommentBar(this.comments);

  final int comments;

  Widget getCommentBar(BuildContext context) {
    String _text;
    if ((comments ?? 0) == 0) {
      _text = Translations.of(context).text("firstToComment");
    } else {
      String number = comments > 999 ? "999+" : "$comments";
      _text = "${Translations.of(context).text("comments")} ($number)";
    }
    return new Padding(
      padding: new EdgeInsets.symmetric(vertical: 2.0),
      child: new Text(
        _text,
        style: new TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Expanded(
      child: new Container(
        padding: new EdgeInsets.symmetric(vertical: 2.0),
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          color: MyColors.muralCommentsBackground,
        ),
        child: getCommentBar(context),
      ),
    );
  }
}
