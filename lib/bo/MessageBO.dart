import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/models/MessageModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/response/MessageResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/HttpUtils.dart';

/// Created by Vitor Martins on 25/08/18.

class MessageBO {
  Future<MessageResponse> getMessages(BuildContext context, UserModel user, UserModel userTo, int page, int pageSize) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/chat/get_messages/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("user_two", () => userTo.email);
    data.putIfAbsent("page", () => page.toString());
    data.putIfAbsent("page_size", () => pageSize.toString());

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("GetMessages - " + json);

      MessageResponse messageResponse = new MessageResponse();
      messageResponse.fromJson(json);

      return messageResponse;
    }
    return null;
  }

  Future<MessageResponse> sendMessage(BuildContext context, UserModel user, MessageModel message) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/chat/send_message/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("user_two", () => user.email);
    data.putIfAbsent("text", () => message.text);
    data.putIfAbsent("email", () => message.user.email);
    data.putIfAbsent("subject", () => message.subject != null ? message.subject.slug : "");
    data.putIfAbsent("create_date", () => message.createDate);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("SendMessage - " + json);

      MessageResponse messageResponse = new MessageResponse();
      messageResponse.fromJson(json);

      return messageResponse;
    }
    return null;
  }

  Future<MessageResponse> sendImageMessage(BuildContext context, UserModel user, MessageModel message, File imageFile) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/chat/send_message/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("user_two", () => user.email);
    data.putIfAbsent("text", () => message.text);
    data.putIfAbsent("email", () => message.user.email);
    data.putIfAbsent("subject", () => message.subject != null ? message.subject.slug : "");
    data.putIfAbsent("create_date", () => message.createDate);

    String content = jsonEncode(data);

    String json = await HttpUtils.postMultipart(context, url, content, "${token.tokenType} ${token.accessToken}", imageFile);

    if(json != null && json.trim().length > 0) {
      print("SendImageMessage - " + json);

      MessageResponse messageResponse = new MessageResponse();
      messageResponse.fromJson(json);

      return messageResponse;
    }
    return null;
  }

  Future<MessageResponse> favoriteMessages(BuildContext context, UserModel user, List<MessageModel> messages, bool favor) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/chat/favorite_messages/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("list_size", () => messages.length.toString());
    data.putIfAbsent("favor", () => favor.toString());

    for(int i = 0; i < messages.length; i++) {
      data.putIfAbsent(i.toString(), () => messages.elementAt(i).id.toString());
    }

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("FavoriteMessages - " + json);

      MessageResponse messageResponse = new MessageResponse();
      messageResponse.fromJson(json);

      return messageResponse;
    }
    return null;
  }
}