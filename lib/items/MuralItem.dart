import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/MuralModel.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/post_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/utils/StringUtils.dart';
import 'package:amadeus/widgets/ClickableImage.dart';
import 'package:amadeus/widgets/mural/CommentBar.dart';
import 'package:amadeus/widgets/mural/FavoriteButton.dart';

abstract class MuralPageItem {}

class LoadMuralItem extends StatelessWidget implements MuralPageItem {
  final Function onPressed;

  LoadMuralItem(this.onPressed);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 40.0,
      decoration: new BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 0.1,
            color: Colors.black,
          ),
        ),
        color: Colors.white,
      ),
      child: new FlatButton(
        onPressed: onPressed,
        child: new Text(
          Translations.of(context).text('loadMorePosts'),
          style: new TextStyle(
            color: MyColors.subjectColor,
          ),
        ),
      ),
    );
  }
}

class PostItem extends StatelessWidget implements MuralPageItem {
  final MuralModel mural;
  final SubjectModel subject;
  final String webserver;
  final bool showCommentBar;
  final bool clickable;
  final Function favoriteCallback;
  final UserModel user;

  PostItem({
    @required this.mural,
    @required this.webserver,
    @required this.favoriteCallback,
    @required this.user,
    @required this.subject,
    this.showCommentBar = true,
    this.clickable = true,
  });

  void onPressComment(BuildContext context) {
    if (!clickable) return;
    Navigator.of(context).push(
      new MaterialPageRoute(
        settings: const RouteSettings(name: 'post-page'),
        builder: (context) => new PostPage(
              userTo: user,
              subject: subject,
              post: mural,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () => onPressComment(context),
      child: new Container(
        color: Colors.white,
        padding: new EdgeInsets.all(10.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: new CircleAvatar(
                backgroundColor: MyColors.primaryWhite,
                backgroundImage: new CachedNetworkImageProvider(
                  webserver + mural.user.imageUrl,
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
                        mural.user.getDisplayName().length > 25
                            ? mural.user.getDisplayName().substring(0, 25) + "..."
                            : mural.user.getDisplayName(),
                        style: new TextStyle(fontSize: 12.0),
                      ),
                      new Row(
                        children: <Widget>[
                          new Container(
                            margin: new EdgeInsets.only(right: 5.0),
                            width: 12.0,
                            height: 12.0,
                            child: new SvgPicture.asset(
                              "images/mural-${mural.action}.svg",
                            ),
                          ),
                          new Text(
                            mural.getDisplayDate(),
                            style: new TextStyle(fontSize: 10.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  new Padding(
                    padding: new EdgeInsets.symmetric(vertical: 5.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Text(
                            StringUtils.stripTags(mural.post),
                            style: new TextStyle(fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  mural.imageUrl != null && mural.imageUrl.isNotEmpty
                      ? new ClickableImage(
                          webserverUrl: webserver,
                          imageUrl: mural.imageUrl,
                          maxHeight: 200.0,
                          margin: new EdgeInsets.only(bottom: 5.0),
                          borderRadius: new BorderRadius.circular(5.0),
                        )
                      : new Container(),
                  showCommentBar
                      ? new Row(
                          children: <Widget>[
                            new CommentBar(mural.comments),
                          ],
                        )
                      : new Container(),
                ],
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new FavoriteButton(mural.favorite, () => favoriteCallback(mural)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
