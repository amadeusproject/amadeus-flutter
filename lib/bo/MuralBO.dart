import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:amadeus/models/CommentModel.dart';
import 'package:amadeus/models/MuralModel.dart';
import 'package:amadeus/response/CommentResponse.dart';
import 'package:amadeus/response/GenericResponse.dart';
import 'package:flutter/material.dart';

import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/response/MuralResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/HttpUtils.dart';

/// Created by Vitor Martins on 29/11/18.

class MuralBO {
  Future<MuralResponse> getPosts(BuildContext context, UserModel user, SubjectModel subject, int page, int pageSize) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/mural/get_posts/";

    Map<String, String> data = new HashMap<String, String>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("subject", () => subject.slug);
    data.putIfAbsent("only_fav", () => "False");
    data.putIfAbsent("only_mine", () => "False");
    data.putIfAbsent("page", () => page.toString());
    data.putIfAbsent("page_size", () => pageSize.toString());

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("GetPosts - $json");

      MuralResponse muralResponse = new MuralResponse();
      muralResponse.fromJson(json);

      return muralResponse;
    }
    return null;
  }

  Future<GenericResponse> favoritePost(BuildContext context, UserModel user, MuralModel post, bool favor) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/mural/favorite/";

    Map<String, dynamic> data = new HashMap<String, dynamic>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("post_id", () => post.id.toString());
    data.putIfAbsent("favor", () => favor.toString());

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("favoritePost - $json");

      GenericResponse genericResponse = new GenericResponse.fromJson(json);

      return genericResponse;
    }
    return null;
  }

  Future<MuralResponse> createPost(BuildContext context, UserModel user, MuralModel post, SubjectModel subject) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/mural/create_post/";

    Map<String, dynamic> data = new HashMap<String, dynamic>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("message", () => post.post);
    data.putIfAbsent("action", () => post.action);
    data.putIfAbsent("subject", () => subject.slug);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("createPost - $json");

      MuralResponse muralResponse = new MuralResponse();
      muralResponse.fromJson(json);

      return muralResponse;
    }
    return null;
  }

  Future<MuralResponse> createImagePost(BuildContext context, UserModel user, MuralModel post, SubjectModel subject, File imageFile) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/mural/create_post/";

    Map<String, dynamic> data = new HashMap<String, dynamic>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("message", () => post.post);
    data.putIfAbsent("action", () => post.action);
    data.putIfAbsent("subject", () => subject.slug);

    String content = jsonEncode(data);

    String json = await HttpUtils.postMultipart(context, url, content, "${token.tokenType} ${token.accessToken}", imageFile);

    if(json != null && json.trim().length > 0) {
      print("createPost - $json");

      MuralResponse muralResponse = new MuralResponse();
      muralResponse.fromJson(json);

      return muralResponse;
    }
    return null;
  }

  Future<CommentResponse> getComments(BuildContext context, UserModel user, MuralModel mural, int page, int pageSize) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/mural/get_comments/";

    Map<String, dynamic> data = new HashMap<String, dynamic>();
    data.putIfAbsent("email", () => user.email);
    data.putIfAbsent("post_id", () => mural.id);    
    data.putIfAbsent("page", () => page);
    data.putIfAbsent("page_size", () => pageSize);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("getComments - $json");

      CommentResponse commentResponse = new CommentResponse();
      commentResponse.fromJson(json);

      return commentResponse;
    }
    return null;
  }

  Future<CommentResponse> createComment(BuildContext context, CommentModel comment) async {
    TokenResponse token = await TokenCacheController.getTokenCache(context);

    String url = "${token.webserverUrl}/api/mural/create_comment/";

    Map<String, dynamic> data = new HashMap<String, dynamic>();
    print(comment.user.email);
    data.putIfAbsent("email", () => comment.user.email);
    data.putIfAbsent("post_id", () => comment.post.id);
    data.putIfAbsent("message", () => comment.comment);

    String content = jsonEncode(data);

    String json = await HttpUtils.post(context, url, content, "${token.tokenType} ${token.accessToken}");

    if(json != null && json.trim().length > 0) {
      print("createComment - $json");

      CommentResponse commentResponse = new CommentResponse();
      commentResponse.fromJson(json);

      return commentResponse;
    }
    return null;
  }
}