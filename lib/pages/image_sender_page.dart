import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:amadeus/bo/MessageBO.dart';
import 'package:amadeus/bo/MuralBO.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/CommentModel.dart';
import 'package:amadeus/models/MessageModel.dart';
import 'package:amadeus/models/MuralModel.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/chat_page.dart';
import 'package:amadeus/pages/mural_page.dart';
import 'package:amadeus/pages/post_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/response/CommentResponse.dart';
import 'package:amadeus/response/MessageResponse.dart';
import 'package:amadeus/response/MuralResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/DateUtils.dart';
import 'package:amadeus/utils/DialogUtils.dart';
import 'package:amadeus/utils/LogoutUtils.dart';
import 'package:amadeus/widgets/InputMessage.dart';

class ImageSenderPage extends StatefulWidget {
  static String tag = 'image-sender-page';
  final File imageFile;
  final UserModel user, userTo;
  final SubjectModel subject;
  final MuralModel post;
  final String inputPlaceholder;
  final ChatPageState chatState;
  final MuralPageState muralState;
  final PostPageState postState;
  ImageSenderPage({
    Key key,
    @required this.imageFile,
    @required this.user,
    @required this.subject,
    @required this.inputPlaceholder,
    this.chatState,
    this.muralState,
    this.postState,
    this.post,
    this.userTo,
  }) : super(key: key);
  @override
  ImageSenderPageState createState() => new ImageSenderPageState(imageFile);
}

class ImageSenderPageState extends State<ImageSenderPage> {
  File _fileToSend;
  File _imageFile;
  TokenResponse _token;
  TextEditingController textCtrl = new TextEditingController();

  ImageSenderPageState(this._imageFile);

  Future<void> checkToken() async {
    if (_token == null) {
      if (await TokenCacheController.hasTokenCache(context)) {
        _token = await TokenCacheController.getTokenCache(context);
        if (_token.isTokenExpired()) {
          _token = await _token.renewToken(context);
          if (_token == null) {
            await DialogUtils.dialog(context);
            Logout.goLogin(context);
          }
        }
      } else {
        await DialogUtils.dialog(context);
        Logout.goLogin(context);
      }
    } else if (_token.isTokenExpired()) {
      _token = await _token.renewToken(context);
      if (_token == null) {
        await DialogUtils.dialog(context);
        Logout.goLogin(context);
      }
    }
  }

  @protected
  Future<void> sendImageMessage() async {
    MessageModel message = new MessageModel(
      textCtrl.text.trimRight(),
      widget.user,
      widget.subject,
      DateUtils.currentDate(),
    );
    await checkToken();
    Navigator.of(context).pop();
    Fluttertoast.showToast(
      msg: Translations.of(context).text('toastSendingImage'),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    try {
      MessageResponse messageResponse = await MessageBO().sendImageMessage(
        context,
        widget.userTo,
        message,
        _fileToSend,
      );

      if (messageResponse != null &&
          messageResponse.success &&
          messageResponse.number == 1) {
        MessageModel sent = messageResponse.data.messageSent;
        widget.chatState.insertMessageSent(sent);
      } else if (messageResponse != null &&
          messageResponse.title != null &&
          messageResponse.title.isNotEmpty &&
          messageResponse.message != null &&
          messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(
          context,
          title: messageResponse.title,
          message: messageResponse.message,
        );
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("sendImageMessage\n" + e.toString());
    }
  }

  @protected
  Future<void> sendImagePost() async {
    MuralModel post = new MuralModel(
      textCtrl.text.trimRight(),
      "comment",
      widget.user,
    );
    await checkToken();
    Navigator.of(context).pop();
    Fluttertoast.showToast(
      msg: Translations.of(context).text('toastSendingImage'),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    try {
      MuralResponse muralResponse = await MuralBO().createImagePost(
        context,
        widget.user,
        post,
        widget.subject,
        _fileToSend,
      );

      if (muralResponse != null &&
          muralResponse.success &&
          muralResponse.number == 1) {
        MuralModel post = muralResponse.newPost;
        widget.muralState.insertPostSent(post);
      } else if (muralResponse != null &&
          muralResponse.title != null &&
          muralResponse.title.isNotEmpty &&
          muralResponse.message != null &&
          muralResponse.message.isNotEmpty) {
        DialogUtils.dialog(
          context,
          title: muralResponse.title,
          message: muralResponse.message,
        );
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("sendImagePost\n" + e.toString());
    }
  }

  @protected
  Future<void> sendImageComment() async {
    CommentModel comment = new CommentModel(
      widget.post,
      textCtrl.text.trimRight(),
      widget.user,
    );
    await checkToken();
    Navigator.of(context).pop();
    Fluttertoast.showToast(
      msg: Translations.of(context).text('toastSendingImage'),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    try {
      CommentResponse commentResponse = await MuralBO().createImageComment(
        context,
        comment,
        _fileToSend,
      );

      if (commentResponse != null &&
          commentResponse.success &&
          commentResponse.number == 1) {
        CommentModel comment = commentResponse.newComment;
        widget.postState.insertCommentSent(comment);
      } else if (commentResponse != null &&
          commentResponse.title != null &&
          commentResponse.title.isNotEmpty &&
          commentResponse.message != null &&
          commentResponse.message.isNotEmpty) {
        DialogUtils.dialog(
          context,
          title: commentResponse.title,
          message: commentResponse.message,
        );
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("sendImageComment\n" + e.toString());
    }
  }

  Future<Null> _cropImage(BuildContext context) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      toolbarTitle: Translations.of(context).text("cropDialogTitle"),
      toolbarColor: MyColors.subjectColor,
    );
    if (croppedFile != null) {
      setState(() {
        _fileToSend = croppedFile;
      });
    }
  }

  Widget getInputWidget() {
    if (widget.chatState != null) {
      return new InputMessage(
        textCtrl,
        sendImageMessage,
        placeholder: widget.inputPlaceholder,
      );
    }
    if (widget.muralState != null) {
      return new InputMessage(
        textCtrl,
        sendImagePost,
        placeholder: widget.inputPlaceholder,
      );
    }
    if (widget.postState != null) {
      return new InputMessage(
        textCtrl,
        sendImageComment,
        placeholder: widget.inputPlaceholder,
      );
    }
    return new Container();
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
        backgroundColor: MyColors.subjectColor,
      ),
      backgroundColor: MyColors.backgroundColor,
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: new Container(
              child: (_fileToSend != null)
                  ? new Image.file(_fileToSend)
                  : new Text(Translations.of(context).text('errorBoxTitle')),
            ),
          ),
          getInputWidget(),
        ],
      ),
    );
  }
}
