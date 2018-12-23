import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_cropper/image_cropper.dart';

import 'package:amadeus/localizations.dart';
import 'package:amadeus/pages/chat_page.dart';
import 'package:amadeus/res/colors.dart';

class ImageSenderPage extends StatefulWidget {
  static String tag = 'image-sender-page';
  final File imageFile;
  final ChatPageState parent;
  ImageSenderPage({Key key, @required this.imageFile, @required this.parent}) : super(key: key);
  @override
  ImageSenderPageState createState () => new ImageSenderPageState(imageFile, parent);
}

class ImageSenderPageState extends State<ImageSenderPage> {

  File _fileToSend;
  File _imageFile;
  ChatPageState _parent;

  ImageSenderPageState(this._imageFile, this._parent);

  void onSendPressed(BuildContext context) {
    _fileToSend = _fileToSend == null ? _imageFile : _fileToSend;
    _parent.sendImageMessage(_parent.textCtrl.text.trimRight(), _fileToSend);
    _parent.textCtrl.clear();
    Navigator.of(context).pop();
  }

  Future<Null> _cropImage(BuildContext context) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      toolbarTitle: Translations.of(context).text("cropDialogTitle"),
      toolbarColor: subjectColor,
    );
    if(croppedFile != null) {
      setState(() {
        _fileToSend = croppedFile;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fileToSend = _imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.crop),
            onPressed: () => _cropImage(context),
          ),
        ],
        backgroundColor: subjectColor,
      ),
      backgroundColor: backgroundColor,
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: (_fileToSend != null) ? new Image.file(_fileToSend) : new Text("Something went wrong"),
            ),
          ),
          _parent.inputWidget(false, () => onSendPressed(context)),
        ],
      ),
    );
  }
}
