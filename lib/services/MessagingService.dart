import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/chat_page.dart';
import 'package:amadeus/pages/home_page.dart';
import 'package:amadeus/pages/participants_page.dart';

/// This class was made for manager Local Notifications. It does not manage any Firebase Notification.

class MessagingService {

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  static AndroidInitializationSettings android = new AndroidInitializationSettings('@mipmap/ic_launcher');
  static IOSInitializationSettings iOS = new IOSInitializationSettings();
  static InitializationSettings initializationSettings = new InitializationSettings(android, iOS);

  Map<String, int> mapUsers = new Map<String, int>();
  int _userId = 0;

  void configure(String page) {
    var methodToRun;
    if(page == HomePage.tag) {
      methodToRun = onSelectNotificationHome;
    } else if (page == ChatPage.tag) {
      methodToRun = onSelectNotificationChat;
    } else if (page == ParticipantsPage.tag) {
      methodToRun = onSelectNotificationParticipants;
    } else {
      methodToRun = (String payload) {};
    }
    flutterLocalNotificationsPlugin.initialize(initializationSettings, selectNotification: methodToRun);
  }

  Future onSelectNotificationHome(String payload) async {
    if (payload != null) {
      var data = json.decode(payload);
      data = json.decode(data['response'])['data']['message_sent'];
      // ignore: unused_local_variable
      var userFrom = UserModel.fromJson(data['user']);
      // ignore: unused_local_variable
      var subject = SubjectModel.fromJson(data['subject']);
    }
    /// TODO - Action when click on notification
  }

  Future onSelectNotificationChat(String payload) async {
    if (payload != null) {
      var data = json.decode(payload);
      data = json.decode(data['response'])['data']['message_sent'];
      // ignore: unused_local_variable
      var userFrom = UserModel.fromJson(data['user']);
      // ignore: unused_local_variable
      var subject = SubjectModel.fromJson(data['subject']);
    }
    /// TODO - Action when click on notification
  }

  Future onSelectNotificationParticipants(String payload) async {
    if (payload != null) {
      var data = json.decode(payload);
      data = json.decode(data['response'])['data']['message_sent'];
      // ignore: unused_local_variable
      var userFrom = UserModel.fromJson(data['user']);
      // ignore: unused_local_variable
      var subject = SubjectModel.fromJson(data['subject']);
    }
    /// TODO - Action when click on notification
  }

  void showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'Channel ID', 'Channel Name', 'Channel Description',
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    
    var notification = message['notification'];
    String title = notification['title'];
    String body = notification['body'];
    var data = message['data'];
    String type = data['type'];
    
    if(type == "chat") {
      var userFrom = UserModel.fromJson(json.decode(data['response'])['data']['message_sent']['user']);
      int notificationId;

      if(mapUsers.containsKey(userFrom.email)) {
        notificationId = mapUsers[userFrom.email];
      } else {
        notificationId = _userId;
        mapUsers.putIfAbsent(userFrom.email, () => _userId);
        _userId++;
      }
      print(notificationId);

      var dataStr = json.encode(data);
      
      await flutterLocalNotificationsPlugin.show(notificationId, title, body, platformChannelSpecifics, payload: dataStr);
    }
  }

  void cleanNotifications(String userEmail) async {
    if(mapUsers.containsKey(userEmail)) {
      await flutterLocalNotificationsPlugin.cancel(mapUsers[userEmail]);
    }
  }

  void cleanAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}