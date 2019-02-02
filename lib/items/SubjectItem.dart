import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/home_page.dart';
import 'package:amadeus/pages/mural_page.dart';
import 'package:amadeus/pages/participants_page.dart';
import 'package:amadeus/pages/pendencies_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/widgets/IconWithBadge.dart';

class SubjectItem extends StatelessWidget {

  final SubjectModel subject;
  final UserModel user;
  final HomePageState parent;

  SubjectItem(this.subject, this.parent, this.user);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget> [
        new Container(
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.circular(4.0),
            color: MyColors.subjectColor,
          ),
          margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _rowItem(context),
          ),
        ),
      ],
    );
  }

  void onPressMessage(BuildContext context) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        settings: const RouteSettings(name: 'participants-page'), 
        builder: (context) => new ParticipantsPage(subject: subject, homePageState: parent),
      )
    ).then((onValue) {
      parent.refreshSubjects(false);
      parent.messagingService.configure(HomePage.tag);
      parent.firebaseMessaging.configure(
        onMessage: parent.onMessageHome,
        onResume: (Map<String, dynamic> message) async {
          parent.refreshSubjects(true);
        }
      );
    });
  }

  void onPressPendency(BuildContext context) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        settings: const RouteSettings(name: 'pendencies-page'), 
        builder: (context) => new PendenciesPage(userTo: user, subject: subject),
      ),
    ).then((onValue) {
      parent.refreshSubjects(false);
      parent.messagingService.configure(HomePage.tag);
      parent.firebaseMessaging.configure(
        onMessage: parent.onMessageHome,
        onResume: (Map<String, dynamic> message) async {
          parent.refreshSubjects(true);
        }
      );
    });
  }

  void onPressMural(BuildContext context) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        settings: const RouteSettings(name: 'mural-page'), 
        builder: (context) => new MuralPage(userTo: user, subject: subject),
      ),
    ).then((onValue) {
      parent.refreshSubjects(false);
      parent.messagingService.configure(HomePage.tag);
      parent.firebaseMessaging.configure(
        onMessage: parent.onMessageHome,
        onResume: (Map<String, dynamic> message) async {
          parent.refreshSubjects(true);
        }
      );
    });
  }

  List<Widget> _rowItem(BuildContext context) {
    final subjectName = new Expanded(
      child: new Text(
        subject.name.toUpperCase(),
        style: TextStyle(
          color: MyColors.primaryWhite,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
    );
    return [
      subjectName,
      new IconWithBadge(
        icon: Icon(Icons.list, color: MyColors.iconsColor,),
        numBadge: subject.muralNotifications,
        onPressCallback: onPressMural,
        buildContext: context,
      ),
      new IconWithBadge(
        icon: Icon(FontAwesomeIcons.comments, color: MyColors.iconsColor,),
        numBadge: subject.notifications,
        onPressCallback: onPressMessage, 
        buildContext: context,
      ),
      new IconWithBadge(
        icon: Icon(Icons.warning, color: MyColors.iconsColor,),
        numBadge: subject.pendencies,
        onPressCallback: onPressPendency,
        buildContext: context,
      ),
    ];
  }
}