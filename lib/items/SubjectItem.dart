import 'package:flutter/material.dart';

import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/pages/participants_page.dart';
import 'package:amadeus/pages/home_page.dart';
import 'package:amadeus/res/colors.dart';

class SubjectItem extends StatelessWidget {

  final SubjectModel subject;
  final HomePageState parent;

  SubjectItem(this.subject, this.parent);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget> [
        new GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              new MaterialPageRoute(
                settings: const RouteSettings(name: 'participants-page'), 
                builder: (context) => new ParticipantsPage(subject: subject, homePageState: parent),
              )
            ).then((onValue) {
              parent.messagingService.configure(HomePage.tag);
              parent.firebaseMessaging.configure(
                onMessage: parent.onMessageHome,
              );
            });
          },
          child: new Container(
            color: primaryBlue,
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _rowItem(),
            ),
          ),
        ),
        new Divider(height: 2.0, color: primaryWhite,),
      ],
    );
  }

  List<Widget> _rowItem() {
    final subjectName = new Expanded(
      child: new Text(
        subject.name.toUpperCase(),
        style: TextStyle(
          color: primaryWhite,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );
    int badgeNumber = (subject.notifications ?? 0) + (subject.pendencies ?? 0);
    if (badgeNumber == 0) {
      return [
        subjectName,
        new Icon(Icons.chevron_right),
      ];
    } else {
      String numNot = badgeNumber > 999 ? "999+" : badgeNumber.toString();
      return [
        subjectName,
        new Row(
          children: <Widget>[
            new Container(
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
            ),
            new Icon(Icons.chevron_right),
          ],
        ),
      ];
    }
  }
}