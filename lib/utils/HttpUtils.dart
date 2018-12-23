import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class HttpUtils {
  static Future<String> post(BuildContext context, String address, String json, String token) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(address));
    request.headers.set('content-type', 'application/json');
    if(token != "") {
      request.headers.set('Authorization', token);
    }

    request.add(utf8.encode(json));

    HttpClientResponse response = await request.close().timeout(new Duration(seconds: 30));

    Completer completer = new Completer();
    StringBuffer contents = new StringBuffer();

    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));

    String reply = await completer.future;

    httpClient.close();

    return reply;
  }

  static Future<String> postMultipart(BuildContext context, String address, String json, String token, File imageFile) async {
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    int length = await imageFile.length();
    Uri uri = Uri.parse(address);

    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile('file', stream, length, filename: basename(imageFile.path));

    if(token.isNotEmpty) {
      request.headers.putIfAbsent('Authorization', () => token);
    }

    request.fields["data"] = json;
    request.files.add(multipartFile);

    var response = await request.send();

    Completer completer = new Completer();
    StringBuffer contents = new StringBuffer();

    response.stream.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));

    String reply = await completer.future;

    return reply;
  }
}