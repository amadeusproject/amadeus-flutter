import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:amadeus/bo/MessageBO.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/cache/UserCacheController.dart';
import 'package:amadeus/items/ChatItems.dart';
import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/MessageModel.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/image_page.dart';
import 'package:amadeus/pages/image_sender_page.dart';
import 'package:amadeus/pages/participants_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/response/MessageResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/services/MessagingService.dart';
import 'package:amadeus/utils/DateUtils.dart';
import 'package:amadeus/utils/DialogUtils.dart';
import 'package:amadeus/utils/LogoutUtils.dart';
import 'package:amadeus/utils/StringUtils.dart';
import 'package:amadeus/widgets/InputMessage.dart';
import 'package:amadeus/widgets/MarqueeWidget.dart';

enum Commands { favMessages, myMessages }
enum ImageChoices { gallery, camera }

class ChatPage extends StatefulWidget {
  static String tag = 'chat-page';
  final SubjectModel subject;
  final UserModel userTo;
  final ParticipantsPageState participantsPageState;
  ChatPage(
      {Key key,
      @required this.userTo,
      @required this.subject,
      this.participantsPageState})
      : super(key: key);
  @override
  ChatPageState createState() =>
      new ChatPageState(userTo, subject, participantsPageState);
}

class ChatPageState extends State<ChatPage> {
  List<ListItem> _items;
  List<MessageModel> _messageList;
  ParticipantsPageState parent;
  SubjectModel _subject;
  TokenResponse _token;
  UserModel _user, _userTo;

  ChatPageState(this._userTo, this._subject, this.parent);

  static final int _pageSize = 50;

  bool _isLastPage = false;
  bool _isLoading = false;
  bool isSelecting = false;
  int messagesSelected = 0;
  int _actualPage = 0;
  int _unseenMsgs = 0;
  bool _onlyMyMessages = false;
  bool _onlyFavMessages = false;

  var _ivPhoto;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  MessagingService messagingService;

  ScrollController scrollController = new ScrollController();
  TextEditingController textCtrl = new TextEditingController();

  File _imageFile;
  final imagePicker = new ImagePicker();

  void updateSelectedMessages(bool increase) {
    if (increase) {
      messagesSelected++;
    } else {
      messagesSelected--;
      if (messagesSelected == 0) {
        isSelecting = false;
      }
    }
    setState(() {
      _updateItems();
    });
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
                    new Icon(
                      Icons.camera,
                      color: MyColors.darkerGray,
                    ),
                    new Padding(
                      padding: EdgeInsets.all(5.0),
                      child: new Text(
                          Translations.of(context).text('imageCameraOption')),
                    ),
                  ],
                ),
              ),
              new SimpleDialogOption(
                onPressed: () => Navigator.pop(context, ImageChoices.gallery),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.photo,
                      color: MyColors.darkerGray,
                    ),
                    new Padding(
                      padding: EdgeInsets.all(5.0),
                      child: new Text(
                          Translations.of(context).text('imageGalleryOption')),
                    ),
                  ],
                ),
              ),
            ],
          );
        })) {
      case ImageChoices.camera:
        _onImageButtonPressed(ImageSource.camera);
        break;
      case ImageChoices.gallery:
        _onImageButtonPressed(ImageSource.gallery);
        break;
    }
  }

  void _onImageButtonPressed(ImageSource source) async {
    PickedFile picked = await imagePicker.getImage(source: source);
    if (picked != null) {
      _imageFile = File(picked.path);
      Navigator.of(context)
          .push(new MaterialPageRoute(
              settings: const RouteSettings(name: 'image-sender-page'),
              builder: (context) {
                return new ImageSenderPage(
                  imageFile: _imageFile,
                  user: _user,
                  subject: _subject,
                  userTo: _userTo,
                  chatState: this,
                  inputPlaceholder:
                      Translations.of(context).text('chatSenderHint'),
                );
              }))
          .then((onValue) {
        _imageFile = null;
      });
    }
  }

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

  Future<dynamic> onMessageChat(Map<String, dynamic> message) async {
    var data = message['data'];
    var type = data['type'].toString();
    if (type == "chat") {
      var userTalk = data['user_from'].toString();
      if (userTalk == _userTo.email) {
        data = json.decode(data['response'])['data']['message_sent'];
        MessageModel messageReceived = new MessageModel.fromJson(data);
        _messageList.insert(0, messageReceived);
        setState(() {
          _updateItems();
        });
        reloadChat();
      } else {
        messagingService.showNotification(message);
        parent.refreshParticipants();
        parent.homePageState.refreshSubjects(false);
      }
    }
  }

  @override
  void initState() {
    scrollController.addListener(() {
      if (!_isLastPage &&
          (scrollController.position.maxScrollExtent - scrollController.offset <
              300.0)) {
        if (!_isLoading) {
          setState(() {
            _isLoading = true;
          });
          loadPage(context, _actualPage + 1);
        }
      }
    });
    loadMessages();
    loadImageProfile();

    _firebaseMessaging.configure(
      onMessage: onMessageChat,
      onResume: (Map<String, dynamic> message) async {
        var data = json.decode(message['response']);
        String type = message['type'].toString();
        if (type == "chat") {
          var userTalk = message['user_from'].toString();
          if (userTalk == _userTo.email) {
            data = data['data']['message_sent'];
            MessageModel messageReceived = new MessageModel.fromJson(data);
            _messageList.insert(0, messageReceived);
            setState(() {
              _updateItems();
            });
            reloadChat();
          }
        }
        parent.refreshParticipants();
        parent.homePageState.refreshSubjects(false);
      },
    );
    messagingService = parent.messagingService;
    messagingService.configure(ChatPage.tag);
    messagingService.cleanNotifications(_userTo.email);
    super.initState();
  }

  void reloadChat() async {
    await checkToken();
    messagingService.cleanNotifications(_userTo.email);
    try {
      MessageResponse messageResponse = await MessageBO()
          .getMessages(context, _user, _userTo, 1, _pageSize * _actualPage);

      if (messageResponse != null &&
          messageResponse.success &&
          messageResponse.number == 1) {
        setState(() {
          _messageList = messageResponse.data.messages;
          _updateItems();
        });
      } else if (messageResponse != null &&
          messageResponse.title != null &&
          messageResponse.title.isNotEmpty &&
          messageResponse.message != null &&
          messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context,
            title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("reloadChat\n" + e.toString());
    }
  }

  void insertMessageSent(MessageModel sent) {
    setState(() {
      _messageList.insert(0, sent);
      _updateItems();
    });
  }

  @protected
  Future<void> loadImageProfile() async {
    if (_userTo.imageUrl != null && _userTo.imageUrl.isNotEmpty) {
      await checkToken();
      String path = _token.webserverUrl + _userTo.imageUrl;
      setState(() {
        _ivPhoto = new CachedNetworkImageProvider(path);
      });
    } else {
      setState(() {
        _ivPhoto = new Image.asset('images/no_image.jpg');
      });
    }
  }

  @protected
  Future<void> loadMessages() async {
    if (await UserCacheController.hasUserCache(context)) {
      _user = await UserCacheController.getUserCache(context);
      _unseenMsgs = _userTo.unseenMsgs;
      if (_unseenMsgs > _pageSize) {
        int missingUnseenPages = (_userTo.unseenMsgs / _pageSize).ceil();
        int pageSize = _pageSize * missingUnseenPages;
        await loadChat(context, pageSize);
      } else {
        await loadChat(context, _pageSize);
      }
    } else {
      await DialogUtils.dialog(context);
      Logout.goLogin(context);
    }
  }

  @protected
  Future<void> loadChat(BuildContext context, int vPageSize) async {
    await checkToken();
    try {
      MessageResponse messageResponse =
          await MessageBO().getMessages(context, _user, _userTo, 1, vPageSize);

      if (messageResponse != null &&
          messageResponse.success &&
          messageResponse.number == 1) {
        _actualPage += 1;
        setState(() {
          _messageList = messageResponse.data.messages;
          _updateItems();
        });
      } else if (messageResponse != null &&
          messageResponse.title != null &&
          messageResponse.title.isNotEmpty &&
          messageResponse.message != null &&
          messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context,
            title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("loadChat\n" + e.toString());
    }
  }

  @protected
  Future<void> loadPage(BuildContext context, int vPageNumber) async {
    await checkToken();
    try {
      MessageResponse messageResponse = await MessageBO()
          .getMessages(context, _user, _userTo, vPageNumber, _pageSize);

      if (messageResponse != null &&
          messageResponse.success &&
          messageResponse.number == 1) {
        _actualPage += 1;
        List<MessageModel> messagesLoaded = messageResponse.data.messages;
        if (messagesLoaded.isNotEmpty) {
          _messageList.addAll(messagesLoaded);
          setState(() {
            _updateItems();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
        if (messagesLoaded == null ||
            messagesLoaded.isEmpty ||
            messagesLoaded.length < _pageSize) {
          _isLastPage = true;
        }
      } else if (messageResponse != null &&
          messageResponse.title != null &&
          messageResponse.title.isNotEmpty &&
          messageResponse.message != null &&
          messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context,
            title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("loadPage\n" + e.toString());
    }
  }

  @protected
  Future<void> sendMessage(String text) async {
    MessageModel message =
        new MessageModel(text, _user, _subject, DateUtils.currentDate());
    _messageList.insert(0, message);
    setState(() {
      _updateItems();
    });
    await checkToken();
    try {
      MessageResponse messageResponse =
          await MessageBO().sendMessage(context, _userTo, message);

      _messageList.removeWhere((test) =>
          test.createDate == message.createDate && test.user == message.user);

      if (messageResponse != null &&
          messageResponse.success &&
          messageResponse.number == 1) {
        MessageModel sent = messageResponse.data.messageSent;

        setState(() {
          _messageList.insert(0, sent);
          _updateItems();
        });
      } else if (messageResponse != null &&
          messageResponse.title != null &&
          messageResponse.title.isNotEmpty &&
          messageResponse.message != null &&
          messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context,
            title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("sendMessage\n" + e.toString());
    }
  }

  @protected
  Future<void> favoriteMessages(
      List<MessageModel> messages, bool setFavorite) async {
    await checkToken();
    try {
      MessageResponse messageResponse = await MessageBO()
          .favoriteMessages(context, _user, messages, setFavorite);

      if (messageResponse != null &&
          messageResponse.success &&
          messageResponse.number == 1) {
        _messageList.forEach((f) {
          if (f.isSelected) {
            f.isFavorite = setFavorite;
            f.isSelected = false;
          }
        });
        setState(() {
          _updateItems();
          messagesSelected = 0;
          isSelecting = false;
        });
      } else if (messageResponse != null &&
          messageResponse.title != null &&
          messageResponse.title.isNotEmpty &&
          messageResponse.message != null &&
          messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context,
            title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("favoriteMessages\n" + e.toString());
    }
  }

  void _updateItems() async {
    List<MessageModel> _messagesToShow = new List.from(_messageList);
    if (_onlyMyMessages && _onlyFavMessages) {
      _messagesToShow = _messagesToShow
          .where((i) => i.isFavorite)
          .toList()
          .where((i) => i.user.email == _user.email)
          .toList();
    } else if (_onlyFavMessages) {
      _messagesToShow = _messagesToShow.where((i) => i.isFavorite).toList();
    } else if (_onlyMyMessages) {
      _messagesToShow =
          _messagesToShow.where((i) => i.user.email == _user.email).toList();
    }
    _items = new List<ListItem>();
    DateTime lastDate;
    for (var i = _messagesToShow.length - 1; i >= 0; i--) {
      if (i == _messagesToShow.length - 1) {
        String formatedDate =
            await DateUtils.displayDate(context, _messagesToShow[i].createDate);
        _items.insert(0, DateItem(formatedDate));
        _items.insert(0, ChatItem(_messagesToShow[i], _user, _token, this));
        lastDate = DateUtils.toDateTime(_messagesToShow[i].createDate);
      } else if (!DateUtils.compareOnlyDate(
          DateUtils.toDateTime(_messagesToShow[i].createDate), lastDate)) {
        String formatedDate =
            await DateUtils.displayDate(context, _messagesToShow[i].createDate);
        _items.insert(0, DateItem(formatedDate));
        _items.insert(0, ChatItem(_messagesToShow[i], _user, _token, this));
        lastDate = DateUtils.toDateTime(_messagesToShow[i].createDate);
      } else {
        _items.insert(0, ChatItem(_messagesToShow[i], _user, _token, this));
      }
    }
  }

  List<Widget> _actionAppBar() {
    return <Widget>[
      PopupMenuButton<Commands>(
        onSelected: (Commands result) {
          switch (result) {
            case Commands.favMessages:
              setState(() {
                _onlyFavMessages = !_onlyFavMessages;
                _updateItems();
              });
              break;
            case Commands.myMessages:
              setState(() {
                _onlyMyMessages = !_onlyMyMessages;
                _updateItems();
              });
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuEntry<Commands>>[
            new CheckedPopupMenuItem(
              checked: _onlyFavMessages,
              value: Commands.favMessages,
              child:
                  new Text(Translations.of(context).text('favoriteMessages')),
            ),
            new CheckedPopupMenuItem(
              checked: _onlyMyMessages,
              value: Commands.myMessages,
              child: new Text(Translations.of(context).text('myMessages')),
            ),
          ];
        },
      ),
    ];
  }

  AppBar _chooseAppBar() {
    if (isSelecting) {
      return new AppBar(
        backgroundColor: MyColors.subjectColor,
        leading: IconButton(
          icon: new Icon(Icons.close),
          onPressed: () {
            _messageList.forEach((f) => f.isSelected = false);
            setState(() {
              _updateItems();
              messagesSelected = 0;
              isSelecting = false;
            });
          },
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.content_copy),
            onPressed: () {
              String stringToClipboard = "";
              _messageList.reversed.forEach((f) {
                if (f.isSelected) {
                  f.isSelected = false;
                  stringToClipboard +=
                      "${f.user.getDisplayName()}: ${StringUtils.stripTags(f.text)}\n";
                }
              });
              Clipboard.setData(new ClipboardData(text: stringToClipboard));
              setState(() {
                _updateItems();
                messagesSelected = 0;
                isSelecting = false;
              });
            },
          ),
          new IconButton(
            icon: new Icon(FontAwesomeIcons.thumbtack),
            onPressed: () {
              int qntFavorites = 0;
              int qntSelected = 0;
              var listToFavorite = new List<MessageModel>();
              _messageList.forEach((f) {
                if (f.isSelected) {
                  listToFavorite.add(f);
                  qntSelected++;
                  if (f.isFavorite) {
                    qntFavorites++;
                  }
                }
              });
              favoriteMessages(listToFavorite, qntSelected != qntFavorites);
            },
          ),
        ],
      );
    } else {
      return new AppBar(
        backgroundColor: MyColors.subjectColor,
        title: new Row(
          children: <Widget>[
            new GestureDetector(
              onTap: () {
                if (_user.imageUrl != null && _user.imageUrl.isNotEmpty) {
                  Navigator.of(context).push(new MaterialPageRoute(
                    settings: const RouteSettings(name: 'image-page'),
                    builder: (context) => new ImagePage(
                      _userTo.imageUrl,
                      _token.webserverUrl,
                      title: _userTo.getDisplayName(),
                    ),
                  ));
                }
              },
              child: new CircleAvatar(
                backgroundColor: MyColors.primaryWhite,
                backgroundImage: _ivPhoto,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0),
              child: new SizedBox(
                width: 170.0,
                child: MarqueeWidget(
                  direction: Axis.horizontal,
                  child: new Text(
                    _userTo.getDisplayName(),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: _actionAppBar(),
      );
    }
  }

  Widget _contentBody() {
    if (_items != null) {
      var chatListView = new ListView.builder(
        reverse: true,
        controller: scrollController,
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          var item = _items[index];
          if (item is DateItem) {
            return item;
          } else if (item is ChatItem) {
            return item;
          }
        },
      );
      return new Stack(
        children: <Widget>[
          chatListView,
          (!_isLoading)
              ? new Container()
              : new Container(
                  height: 50.0,
                  alignment: Alignment.topCenter,
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.white70Transparency,
                  ),
                  child: new Center(
                    child: new CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          MyColors.primaryBlue),
                    ),
                  ),
                ),
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
            Translations.of(context).text('loadingMessages'),
            style: new TextStyle(color: MyColors.darkerGray),
          )
        ],
      ),
    );
  }

  void _onPressed() {
    if (textCtrl.text.trimRight().isNotEmpty) {
      sendMessage(textCtrl.text.trimRight());
      textCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async {
        if (isSelecting) {
          _messageList.forEach((f) => f.isSelected = false);
          setState(() {
            _updateItems();
            messagesSelected = 0;
            isSelecting = false;
          });
          return false;
        } else {
          return true;
        }
      },
      child: new Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: _chooseAppBar(),
        body: new Center(
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 5.0),

              /// MARK - Body
              new Flexible(
                child: _contentBody(),
              ),

              /// MARK - Input
              new InputMessage(
                textCtrl: textCtrl,
                onSendPressed: _onPressed,
                placeholder: Translations.of(context).text('chatSenderHint'),
                showCameraIcon: true,
                onCameraPressed: _openDialogToChoose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
