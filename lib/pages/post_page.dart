import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:amadeus/bo/MuralBO.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/items/CommentItem.dart';
import 'package:amadeus/items/MuralItem.dart';
import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/CommentModel.dart';
import 'package:amadeus/models/MuralModel.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/image_sender_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/response/CommentResponse.dart';
import 'package:amadeus/response/GenericResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/DialogUtils.dart';
import 'package:amadeus/utils/LogoutUtils.dart';
import 'package:amadeus/widgets/InputMessage.dart';
import 'package:amadeus/widgets/Loading.dart';

enum ImageChoices {gallery, camera}

class PostPage extends StatefulWidget {
  static String tag = 'post-page';
  final SubjectModel subject;
  final UserModel userTo;
  final MuralModel post;
  PostPage(
      {Key key,
      @required this.userTo,
      @required this.subject,
      @required this.post})
      : super(key: key);
  @override
  PostPageState createState() => new PostPageState(userTo, subject, post);
}

class PostPageState extends State<PostPage> {
  UserModel _user;
  SubjectModel _subject;
  MuralModel _post;
  List<CommentModel> _comments;
  List<CommentPageItem> _items;
  TokenResponse _token;
  TextEditingController textCtrl = new TextEditingController();
  File _imageFile;

  int _actualPage = 0;
  int _pageSize = 20;
  bool _isLastPage = false;
  bool _isLoading = false;

  PostPageState(this._user, this._subject, this._post);

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

  Future _openDialogToChoose() async {
    switch (await showDialog<ImageChoices>(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text(Translations.of(context).text('imageChooserTitle')),
          children: <Widget>[
            new SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageChoices.camera),
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.camera, color: darkerGray,),
                  new Padding(
                    padding: EdgeInsets.all(5.0),
                    child: new Text(Translations.of(context).text('imageCameraOption')),
                  ),
                ],
              ),
            ),
            new SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ImageChoices.gallery),
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.photo, color: darkerGray,),
                  new Padding(
                    padding: EdgeInsets.all(5.0),
                    child: new Text(Translations.of(context).text('imageGalleryOption')),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    )) {
      case ImageChoices.camera:
        _onImageButtonPressed(ImageSource.camera);
        break;
      case ImageChoices.gallery:
        _onImageButtonPressed(ImageSource.gallery);
        break;
    }
  }

  void _onImageButtonPressed(ImageSource source) async {
    _imageFile = await ImagePicker.pickImage(source: source);
    if(_imageFile != null) {
      Navigator.of(context).push(
        new MaterialPageRoute(
          settings: const RouteSettings(name: 'image-sender-page'), 
          builder: (context) {
            return new ImageSenderPage(
              imageFile: _imageFile,
              user: _user,
              subject: _subject,
              postState: this,
              post: _post,
              inputPlaceholder: Translations.of(context).text('postSenderHint'),
            );
          }
        )
      ).then((onValue) {
        _imageFile = null;
      });
    }
  }

  void _updateItems() async {
    _items = new List<CommentPageItem>();
    if (_comments == null) return;
    for (int i = _comments.length - 1; i >= 0; i--) {
      _items.insert(
        0,
        CommentItem(
          _comments[i],
          _token.webserverUrl,
          _user,
        ),
      );
    }
    if (!_isLastPage) {
      _items.add(LoadPostItem(loadComments));
    }
  }

  Future<void> loadComments() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    await checkToken();

    try {
      _isLoading = true;
      CommentResponse commentResponse = await MuralBO().getComments(context, _user, _post, _actualPage, _pageSize,);
      if (commentResponse != null) {
        if (commentResponse.success && commentResponse.number == 1) {
          _actualPage += 1;
          List<CommentModel> commentsLoaded = commentResponse.data.comments;
          if (commentsLoaded.isNotEmpty) {
            if (_comments == null) _comments = new List();
            _comments.addAll(commentsLoaded);
            setState(() {
              _updateItems();
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
          if (commentsLoaded == null ||
              commentsLoaded.isEmpty ||
              commentsLoaded.length < _pageSize) {
            _isLastPage = true;
            setState(() {
              _updateItems();
              _isLoading = false;
            });
          }
        } else if (commentResponse.title != null &&
            commentResponse.title.isNotEmpty &&
            commentResponse.message != null &&
            commentResponse.message.isNotEmpty) {
          DialogUtils.dialog(
            context,
            title: commentResponse.title,
            message: commentResponse.message,
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        DialogUtils.dialog(context);
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("loadComments\n" + e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> favoritePost(MuralModel post) async {
    await checkToken();

    try {
      GenericResponse genericResponse =
          await MuralBO().favoritePost(context, _user, post, !post.favorite);
      if (genericResponse != null &&
          genericResponse.success &&
          genericResponse.number == 1) {
        post.favorite = !post.favorite;
        setState(() {
          _updateItems();
        });
      } else if (genericResponse != null &&
          genericResponse.title != null &&
          genericResponse.title.isNotEmpty &&
          genericResponse.message != null &&
          genericResponse.message.isNotEmpty) {
        DialogUtils.dialog(context,
            title: genericResponse.title, message: genericResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("favoritePost\n" + e.toString());
    }
  }

  void insertCommentSent(CommentModel comment) {
    setState(() {
      _comments.insert(0, comment);
      _updateItems();
    });
  }

  Future<void> createComment() async {
    if (textCtrl.text.trimRight().isNotEmpty) {
      await checkToken();
      CommentModel comment = new CommentModel(
        _post,
        textCtrl.text.trimRight(),
        _user,
      );
      setState(() {
        _comments.insert(0, comment);
        _updateItems();
      });

      textCtrl.clear();
      FocusScope.of(context).requestFocus(new FocusNode());

      try {
        CommentResponse commentResponse = await MuralBO().createComment(
          context,
          comment,
        );

        _comments.removeWhere((test) => test.createDate == comment.createDate && test.user == comment.user);

        if (commentResponse != null &&
            commentResponse.success &&
            commentResponse.number == 1) {
          CommentModel comment = commentResponse.newComment;

          _comments.insert(0, comment);
          setState(() {
            _updateItems();
          });
        } else if (commentResponse != null &&
            commentResponse.title != null &&
            commentResponse.title.isNotEmpty &&
            commentResponse.message != null &&
            commentResponse.message.isNotEmpty) {
          _comments.removeWhere((test) => test.createDate == comment.createDate && test.user == comment.user);
          setState(() {
            _updateItems();
          });
          DialogUtils.dialog(
            context,
            title: commentResponse.title,
            message: commentResponse.message,
          );
        } else {
          _comments.removeWhere((test) => test.createDate == comment.createDate && test.user == comment.user);
          setState(() {
            _updateItems();
          });
          DialogUtils.dialog(context);
        }
      } catch (e) {
        _comments.removeWhere((test) => test.createDate == comment.createDate && test.user == comment.user);
        setState(() {
          _updateItems();
        });
        DialogUtils.dialog(context, erro: e.toString());
        print("createPost\n" + e.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Widget _contentBody() {
    if (_items != null) {
      if (_items.length == 0) {
        return new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                Translations.of(context).text('emptyComments'),
                style: new TextStyle(color: darkerGray),
              )
            ],
          ),
        );
      }
      var listView = new ListView.separated(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          var item = _items[index];
          if (item is CommentItem) {
            return item;
          } else if (item is LoadPostItem) {
            return item;
          }
        },
        separatorBuilder: (BuildContext context, int index) {
          return new Divider(height: 1.0);
        },
      );
      return new Stack(
        children: <Widget>[
          listView,
          _isLoading
              ? new Container(
                  alignment: Alignment.topCenter,
                  child: new Loading(),
                )
              : new Container(),
        ],
      );
    }
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
          new SizedBox(height: 5.0),
          new Text(
            Translations.of(context).text('loadingComments'),
            style: new TextStyle(color: darkerGray),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: backgroundColor,
      appBar: new AppBar(
        backgroundColor: subjectColor,
        title:
            new Text((_subject != null ? _subject.name.toUpperCase() : "Null")),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.list,
              color: iconsColor,
            ),
            onPressed: null,
            disabledColor: iconsColor,
          ),
        ],
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            _token != null
                ? new PostItem(
                    mural: _post,
                    webserver: _token.webserverUrl,
                    favoriteCallback: favoritePost,
                    user: _user,
                    subject: _subject,
                    showCommentBar: false,
                    clickable: false,
                  )
                : new Container(),
            new Divider(height: 1.0),
            new Flexible(
              child: _contentBody(),
            ),
            new InputMessage(
              textCtrl,
              createComment,
              placeholder: Translations.of(context).text('postSenderHint'),
              showCameraIcon: true,
              onCameraPressed: _openDialogToChoose,
            ),
          ],
        ),
      ),
    );
  }
}
