import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/home_page.dart';
import 'package:amadeus/pages/participants_page.dart';
import 'package:amadeus/pages/pendencies_page.dart';
import 'package:amadeus/res/colors.dart';

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
            color: subjectColor,
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

  Widget iconWithBadge({@required Icon icon, @required int numBadge, @required Function onPress, @required BuildContext context}) {
    Widget badge;
    if(numBadge > 0) {
      String qtdPendencies = numBadge > 99 ? "99+" : numBadge.toString();
      badge = new Container(
        margin: new EdgeInsets.all(5.0),
        width: 20.0,
        height: 20.0,
        decoration: new BoxDecoration(
          color: primaryRed,
          boxShadow: null,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: new Center(
          child: new Text(qtdPendencies, style: new TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),),
        ),
      );
    } else {
      badge = new Container(width: 0.0, height: 0.0,);
    }
    return new Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        new Center(
          child: new IconButton(
            onPressed: () => onPress(context),
            icon: icon,
          ),
        ),
        badge,
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
      parent.messagingService.configure(HomePage.tag);
      parent.firebaseMessaging.configure(
        onMessage: parent.onMessageHome,
      );
    });
  }

  List<Widget> _rowItem(BuildContext context) {
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
    return [
      subjectName,
      iconWithBadge(
        icon: Icon(FontAwesomeIcons.envelope, color: iconsColor,),
        numBadge: subject.notifications,
        onPress: onPressMessage, 
        context: context
      ),
      iconWithBadge(
        icon: Icon(Icons.warning, color: iconsColor,),
        numBadge: subject.pendencies,
        onPress: onPressPendency,
        context: context
      ),
    ];
  }
}