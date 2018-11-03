import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:amadeus/bo/ParticipantsBO.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/cache/UserCacheController.dart';
import 'package:amadeus/items/ParticipantItem.dart';
import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/home_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/response/ParticipantsResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/services/MessagingService.dart';
import 'package:amadeus/utils/DialogUtils.dart';
import 'package:amadeus/utils/LogoutUtils.dart';

class ParticipantsPage extends StatefulWidget {
  static String tag = 'participants-page';
  final SubjectModel subject;
  final HomePageState homePageState;
  ParticipantsPage({Key key, @required this.subject, @required this.homePageState}) : super(key: key);
  @override
  ParticipantsPageState createState() => new ParticipantsPageState(subject, homePageState);
}

class ParticipantsPageState extends State<ParticipantsPage> {

  List<UserModel> _participants;
  SubjectModel _subject;
  UserModel _user;
  TokenResponse _token;
  final HomePageState homePageState;

  ParticipantsPageState(this._subject, this.homePageState);

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  MessagingService messagingService;

  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<void> checkToken() async {
    if(_token == null) {
      if(await TokenCacheController.hasTokenCache(context)) {
        _token = await TokenCacheController.getTokenCache(context);
        if(_token.isTokenExpired()) {
          _token = await _token.renewToken(context);
          if(_token == null) {
            DialogUtils.dialog(context);
            Logout.goLogin(context);
          }
        }
      } else {
        DialogUtils.dialog(context);
        Logout.goLogin(context);
      }
    } else if(_token.isTokenExpired()) {
      _token = await _token.renewToken(context);
      if(_token == null) {
        DialogUtils.dialog(context);
        Logout.goLogin(context);
      }
    }
  }

  Future<dynamic> onMessageParticipants(Map<String, dynamic> message) async {
    var response = message['data']['response'];
    var data = jsonDecode(response)['data'];
    var subject = data['message_sent']['subject'];
    if(subject['slug'] == _subject.slug) {
      refreshParticipants();
    }
    messagingService.showNotification(message);
  }

  @override
  void initState() {
    loadParticipants();
    firebaseMessaging.configure(
      onMessage: onMessageParticipants,
    );
    messagingService = homePageState.messagingService;
    messagingService.configure(ParticipantsPage.tag);
    super.initState();
  }

  Future<void> refreshParticipants() async {
    refreshKey.currentState?.show(atTop: false);
    await checkToken();
    /// Get participants
    try {
      ParticipantsResponse participantsResponse = await ParticipantsBO().getParticipants(context, _user, _subject.slug);
      if(participantsResponse != null) {
        if(participantsResponse.success && participantsResponse.number == 1) {
          setState(() {
            _participants = participantsResponse.data.participants;
            _participants.sort((a, b) => a.getDisplayName().compareTo(b.getDisplayName()));
            _participants.sort((a, b) => b.unseenMsgs.compareTo(a.unseenMsgs));
          });
        } else if(participantsResponse.title != null && participantsResponse.title.isNotEmpty && participantsResponse.message != null && participantsResponse.message.isNotEmpty) {
          DialogUtils.dialog(context, title: participantsResponse.title, message: participantsResponse.message);
        }
      } else {
        DialogUtils.dialog(context);
      }
    } catch(e) {
      DialogUtils.dialog(context, erro: e.toString());
      print(e);
    }
  }

  @protected
  Future<void> loadParticipants() async {
    /// Getting user
    if(await UserCacheController.hasUserCache(context)) {
      _user = await UserCacheController.getUserCache(context);
      await checkToken();
      try {
        ParticipantsResponse participantsResponse = await ParticipantsBO().getParticipants(context, _user, _subject.slug);
        if(participantsResponse != null) {
          if(participantsResponse.success && participantsResponse.number == 1) {
            setState(() {
              _participants = participantsResponse.data.participants;
              _participants.sort((a, b) => a.getDisplayName().compareTo(b.getDisplayName()));
              _participants.sort((a, b) => b.unseenMsgs.compareTo(a.unseenMsgs));
            });
           } else if(participantsResponse.title != null && participantsResponse.title.isNotEmpty && participantsResponse.message != null && participantsResponse.message.isNotEmpty) {
            DialogUtils.dialog(context, title: participantsResponse.title, message: participantsResponse.message);
          }
        } else {
          DialogUtils.dialog(context);
        }
      } catch(e) {
        DialogUtils.dialog(context, erro: e.toString());
        print(e);
      }
    } else {
      DialogUtils.dialog(context);
      Logout.goLogin(context);
    }
  }

  Widget _contentBody() {
    if(_participants != null) {
      return new Theme(
        data: new ThemeData(
          hintColor: primaryBlue,
        ),
        child: new RefreshIndicator(
          key: refreshKey,
          onRefresh: refreshParticipants,
          child: new Theme(
            data: Theme.of(context),
            child: new ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if(!_participants[index].isStaff) {
                  return ParticipantItem(_participants[index], _subject, _token.webserverUrl, this, homePageState);
                } else {
                  return new Container();
                }
              },
              itemCount: _participants.length,
            ),
          ),
        ),
      );
    }
    return new Theme(
      data: new ThemeData(
        hintColor: primaryBlue,
      ),
      child: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new CircularProgressIndicator(),
            new SizedBox(height: 10.0),
            new Text(Translations.of(context).text('loadingParticipants'), style: new TextStyle(color: primaryBlue),)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text((_subject != null ? _subject.name.toUpperCase() : "Null")),
      ),
      backgroundColor: primaryWhite,
      body: _contentBody(),
    );
  }
}