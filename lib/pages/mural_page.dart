import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:amadeus/bo/MuralBO.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/items/MuralItem.dart';
import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/MuralModel.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/image_sender_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/response/GenericResponse.dart';
import 'package:amadeus/response/MuralResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/DialogUtils.dart';
import 'package:amadeus/utils/LogoutUtils.dart';
import 'package:amadeus/widgets/InputMessage.dart';
import 'package:amadeus/widgets/Loading.dart';

enum Commands {favPosts}
enum ImageChoices {gallery, camera}

class MuralPage extends StatefulWidget {
  static String tag = 'mural-page';
  final SubjectModel subject;
  final UserModel userTo;
  MuralPage({Key key, @required this.userTo, @required this.subject})
      : super(key: key);
  @override
  MuralPageState createState() => new MuralPageState(userTo, subject);
}

class MuralPageState extends State<MuralPage> {
  UserModel _user;
  SubjectModel _subject;
  List<MuralModel> _posts;
  List<MuralPageItem> _items;
  TokenResponse _token;
  TextEditingController textCtrl = new TextEditingController();
  File _imageFile;

  int _actualPage = 0;
  int _pageSize = 20;
  bool _isLastPage = false;
  bool _isLoading = false;
  bool _onlyFavPosts = false;

  MuralPageState(this._user, this._subject);

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
                  new Icon(Icons.camera, color: MyColors.darkerGray,),
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
                  new Icon(Icons.photo, color: MyColors.darkerGray,),
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
              muralState: this,
              inputPlaceholder: Translations.of(context).text('muralSenderHint'),
            );
          }
        )
      ).then((onValue) {
        _imageFile = null;
      });
    }
  }

  void _updateItems() async {
    _items = new List<MuralPageItem>();
    if (_posts == null) return;
    for (int i = _posts.length - 1; i >= 0; i--) {
      if(_onlyFavPosts) {
        if(_posts[i].favorite) {
           _items.insert(
            0,
            PostItem(
              mural: _posts[i],
              webserver: _token.webserverUrl,
              favoriteCallback: favoritePost,
              user: _user,
              subject: _subject,
            ),
          );
        }
      } else {
        _items.insert(
          0,
          PostItem(
            mural: _posts[i],
            webserver: _token.webserverUrl,
            favoriteCallback: favoritePost,
            user: _user,
            subject: _subject,
          ),
        );
      }
    }
    if (!_isLastPage) {
      _items.add(LoadMuralItem(loadPosts));
    }
  }

  Future<void> loadPosts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    await checkToken();

    try {
      _isLoading = true;
      MuralResponse muralResponse = await MuralBO()
          .getPosts(context, _user, _subject, _actualPage, _pageSize);
      if (muralResponse != null) {
        if (muralResponse.success && muralResponse.number == 1) {
          _actualPage += 1;
          List<MuralModel> postsLoaded = muralResponse.data.posts;
          if (postsLoaded.isNotEmpty) {
            if (_posts == null) _posts = new List();
            _posts.addAll(postsLoaded);
            setState(() {
              _updateItems();
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
          if (postsLoaded == null ||
              postsLoaded.isEmpty ||
              postsLoaded.length < _pageSize) {
            _isLastPage = true;
            setState(() {
              _updateItems();
              _isLoading = false;
            });
          }
        } else if (muralResponse.title != null &&
            muralResponse.title.isNotEmpty &&
            muralResponse.message != null &&
            muralResponse.message.isNotEmpty) {
          DialogUtils.dialog(
            context,
            title: muralResponse.title,
            message: muralResponse.message,
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
      print("loadPosts\n" + e.toString());
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

  void insertPostSent(MuralModel post) {
    if (_posts == null) _posts = new List<MuralModel>();
    _posts.insert(0, post);
    setState(() {
      _updateItems();
    });
  }

  Future<void> createPost() async {
    if (textCtrl.text.trimRight().isNotEmpty) {
      await checkToken();
      MuralModel post = new MuralModel(textCtrl.text.trimRight(), "comment", _user);
      insertPostSent(post);

      textCtrl.clear();
      FocusScope.of(context).requestFocus(new FocusNode());

      try {
        MuralResponse muralResponse = await MuralBO().createPost(context, _user, post, _subject);

        _posts.removeWhere((test) =>
            test.createDate == post.createDate && test.user == post.user);

        if (muralResponse != null &&
            muralResponse.success &&
            muralResponse.number == 1) {
          MuralModel post = muralResponse.newPost;
          if (_posts == null) _posts = new List<MuralModel>();
          _posts.insert(0, post);
          setState(() {
            _updateItems();
          });
        } else if (muralResponse != null &&
            muralResponse.title != null &&
            muralResponse.title.isNotEmpty &&
            muralResponse.message != null &&
            muralResponse.message.isNotEmpty) {
          _posts.removeWhere((test) =>
              test.createDate == post.createDate && test.user == post.user);
          setState(() {
            _updateItems();
          });
          DialogUtils.dialog(context,
              title: muralResponse.title, message: muralResponse.message);
        } else {
          _posts.removeWhere((test) =>
              test.createDate == post.createDate && test.user == post.user);
          setState(() {
            _updateItems();
          });
          DialogUtils.dialog(context);
        }
      } catch (e) {
        _posts.removeWhere((test) =>
            test.createDate == post.createDate && test.user == post.user);
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
    loadPosts();
  }

  Widget _contentBody() {
    if (_items != null) {
      if (_items.length == 0) {
        return new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                Translations.of(context).text('emptyPosts'),
                style: new TextStyle(color: MyColors.darkerGray),
              )
            ],
          ),
        );
      }
      ListView listView = new ListView.separated(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          var item = _items[index];
          if (item is PostItem) {
            return item;
          } else if (item is LoadMuralItem) {
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
            Translations.of(context).text('loadingPosts'),
            style: new TextStyle(color: MyColors.darkerGray),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: new AppBar(
        backgroundColor: MyColors.subjectColor,
        title: new Text(_subject != null ? _subject.name.toUpperCase() : "Null"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(
              Icons.list,
              color: MyColors.iconsColor,
            ),
            onPressed: null,
            disabledColor: MyColors.iconsColor,
          ),
          PopupMenuButton<Commands>(
            onSelected: (Commands result) {
              switch (result) {
                case Commands.favPosts:
                  setState(() {
                    _onlyFavPosts = !_onlyFavPosts;
                    _updateItems();
                  });
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<Commands>>[
                new CheckedPopupMenuItem(
                  checked: _onlyFavPosts,
                  value: Commands.favPosts,
                  child: new Text(Translations.of(context).text('favoriteMessages')),
                ),
              ];
            },
          ),
        ],
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new Flexible(
              child: _contentBody(),
            ),
            new InputMessage(
              textCtrl: textCtrl,
              onSendPressed: createPost,
              placeholder: Translations.of(context).text('muralSenderHint'),
              showCameraIcon: true,
              onCameraPressed: _openDialogToChoose,
            ),
          ],
        ),
      ),
    );
  }
}
