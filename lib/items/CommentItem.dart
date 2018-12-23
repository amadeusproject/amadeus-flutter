import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/CommentModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/utils/StringUtils.dart';
import 'package:amadeus/widgets/ClickableImage.dart';

abstract class CommentPageItem {}

class LoadPostItem extends StatelessWidget implements CommentPageItem {

  final Function onPressed;
  final bool loading = false;

  LoadPostItem(this.onPressed);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 40.0,
      decoration: new BoxDecoration(
        color: Colors.white,
      ),
      child: new FlatButton(
        onPressed: onPressed,
        child: new Text(
          Translations.of(context).text('loadMoreComments'),
          style: new TextStyle(
            color: MyColors.subjectColor,
          ),
        ),
      ),
    );
  }
}

class CommentItem extends StatelessWidget implements CommentPageItem {
  final CommentModel comment;
  final String _webserver;
  final UserModel user;

  CommentItem(this.comment, this._webserver, this.user);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      padding: new EdgeInsets.all(10.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: new CircleAvatar(
              maxRadius: 15.0,
              backgroundColor: MyColors.primaryWhite,
              backgroundImage: new CachedNetworkImageProvider(
                _webserver + comment.user.imageUrl,
              ),
            ),
          ),
          new Expanded(
            child: new Column(
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new Text(
                      comment.user.getDisplayName().length > 25
                          ? comment.user.getDisplayName().substring(0, 25) +
                              "..."
                          : comment.user.getDisplayName(),
                      style: new TextStyle(fontSize: 12.0),
                    ),
                    new Padding(
                      child: new Text(
                        comment.getDisplayDate(),
                        style: new TextStyle(fontSize: 10.0),
                      ),
                      padding: new EdgeInsets.only(right: 18.0),
                    ),
                  ],
                ),
                new Padding(
                  padding: new EdgeInsets.fromLTRB(0.0, 5.0, 20.0, 5.0),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Text(
                          StringUtils.stripTags(comment.comment),
                          style: new TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ),
                comment.imageUrl != null && comment.imageUrl.isNotEmpty
                    ? new ClickableImage(
                        webserverUrl: _webserver,
                        imageUrl: comment.imageUrl,
                        maxHeight: 200.0,
                        margin: new EdgeInsets.only(bottom: 5.0),
                        borderRadius: new BorderRadius.circular(5.0),
                      )
                    : new Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
