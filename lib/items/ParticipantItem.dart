import 'package:flutter/material.dart';

import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/chat_page.dart';
import 'package:amadeus/pages/home_page.dart';
import 'package:amadeus/pages/participants_page.dart';
import 'package:amadeus/res/colors.dart';

class ParticipantItem extends StatelessWidget {

  final SubjectModel _subject;
  final String _webserver;
  final UserModel _user;
  final HomePageState homePageState;
  final ParticipantsPageState parent;

  ParticipantItem(this._user, this._subject, this._webserver, this.parent, this.homePageState);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget> [
        new GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                settings: const RouteSettings(name: 'chat-page'), 
                builder: (context) => new ChatPage(userTo: _user, subject: _subject, participantsPageState: parent,),
              ),
            ).then((onValue) {
              parent.messagingService.configure(ParticipantsPage.tag);
              parent.firebaseMessaging.configure(
                onMessage: parent.onMessageParticipants,
                onResume: (Map<String, dynamic> message) async {
                  parent.refreshParticipants();
                },
              );
            });
            if(_user.unseenMsgs > 0) {
              parent.refreshParticipants();
              homePageState.refreshSubjects(false);
            }
          },
          child: new Container(
            color: primaryWhite,
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _rowItem(context),
            ),
          ),
        ),
        new Divider(
          height: 2.0,
          color: primaryGray,
        ),
      ],
    );
  }

  List<Widget> _rowItem(BuildContext context) {

    Widget badge(String numNot) {
      return new Container(
        constraints: BoxConstraints(
          minWidth: 25.0,
        ),
        margin: EdgeInsets.only(right: 5.0),
        padding: EdgeInsets.all(5.0),
        decoration: new BoxDecoration(
          color: primaryRed,
          boxShadow: null,
          borderRadius: BorderRadius.circular(12.5),
        ),
        height: 25.0,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              numNot, 
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: primaryWhite,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      );
    }

    final userNameWidget = new Expanded(
      child: new Text(
        _user.getDisplayName(),
        style: TextStyle(
          color: primaryBlack,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );

    final userAvatarWidget = new Padding(
      padding: EdgeInsets.only(right: 20.0),
      child: new CircleAvatar(
        backgroundColor: primaryWhite,
        backgroundImage: new NetworkImage(_webserver + _user.imageUrl),
      ),
    );

    if (_user.unseenMsgs == 0) {
      return [
        userAvatarWidget,
        userNameWidget,
      ];
    } else {
      String numNot = _user.unseenMsgs.toString();
      int numLen = numNot.length;
      if(numLen >= 4) {
        numNot = "999+";
      }
      return [
        userAvatarWidget,
        userNameWidget,
        badge(numNot),
      ];
    }
  }
}
