import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

enum Commands {favMessages, myMessages}
enum ImageChoices {gallery, camera}

class ChatPage extends StatefulWidget {
  static String tag = 'chat-page';
  final SubjectModel subject;
  final UserModel userTo;
  final ParticipantsPageState participantsPageState;
  ChatPage({Key key, @required this.userTo, @required this.subject, this.participantsPageState}) : super(key: key);
  @override
  ChatPageState createState() => new ChatPageState(userTo, subject, participantsPageState);
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

  void updateSelectedMessages(bool increase) {
    if(increase) {
      messagesSelected++;
    } else {
      messagesSelected--;
      if(messagesSelected == 0) {
        isSelecting = false;
      }
    }
    setState(() {
      _updateItems();
    });
  }

  Widget _cameraIcon() {
    return new IconButton(
      icon: new Icon(Icons.camera_alt),
      color: primaryGray,
      onPressed: () {
        _openDialogToChoose();
      },
    );
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
          builder: (context) => new ImageSenderPage(imageFile: _imageFile, parent: this),
        )
      ).then((onValue) {
        _imageFile = null;
      });
    }
  }

  Future<void> checkToken() async {
    if(_token == null) {
      if(await TokenCacheController.hasTokenCache(context)) {
        _token = await TokenCacheController.getTokenCache(context);
        if(_token.isTokenExpired()) {
          _token = await _token.renewToken(context);
          if(_token == null) {
            await DialogUtils.dialog(context);
            Logout.goLogin(context);
          }
        }
      } else {
        await DialogUtils.dialog(context);
        Logout.goLogin(context);
      }
    } else if(_token.isTokenExpired()) {
      _token = await _token.renewToken(context);
      if(_token == null) {
        await DialogUtils.dialog(context);
        Logout.goLogin(context);
      }
    }
  }

  Future<dynamic> onMessageChat(Map<String, dynamic> message) async {
    var data = message['data'];
    var type = data['type'].toString();
    if(type == "chat") {
      var userTalk = data['user_from'].toString();
      print(userTalk);
      if(userTalk == _userTo.email) {
        reloadChat();
      } else {
        messagingService.showNotification(message);
      }
    }
  }

  @override
  void initState() {
    scrollController.addListener(() {
      if(!_isLastPage && (scrollController.position.maxScrollExtent - scrollController.offset < 300.0) ) {
        if(!_isLoading) {
          setState(() {
            _isLoading = true;
          });
          loadPage(context, _actualPage+1);
        }
      }
    });
    loadMessages();
    loadImageProfile();

    _firebaseMessaging.configure(
      onMessage: onMessageChat,
    );
    messagingService = parent.messagingService;
    messagingService.configure(ChatPage.tag);
    messagingService.cleanNotifications(_userTo.email);
    super.initState();
  }

  void reloadChat() async {
    await checkToken();
    try {
      MessageResponse messageResponse = await MessageBO().getMessages(context, _user, _userTo, 1, _pageSize*_actualPage);

      if(messageResponse != null && messageResponse.success && messageResponse.number == 1) {
        setState(() {
          _messageList = messageResponse.data.messages;
          _updateItems();
        });
      } else if(messageResponse != null && messageResponse.title != null && messageResponse.title.isNotEmpty && messageResponse.message != null && messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context, title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch(e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("reloadChat\n" + e.toString());
    }
  }

  @protected
  Future<void> loadImageProfile() async {
    if(_userTo.imageUrl != null && _userTo.imageUrl.isNotEmpty) {
      await checkToken();
      String path = _token.webserverUrl + _userTo.imageUrl;
      setState(() {
        _ivPhoto = new NetworkImage(path);
      });
    } else {
      setState(() {
        _ivPhoto = new Image.asset('images/no_image.jpg');
      });
    }
  }
  
  @protected
  Future<void> loadMessages() async {
    if(await UserCacheController.hasUserCache(context)) {
      _user = await UserCacheController.getUserCache(context);
      _unseenMsgs = _userTo.unseenMsgs;
      if(_unseenMsgs > _pageSize) {
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
      MessageResponse messageResponse = await MessageBO().getMessages(context, _user, _userTo, 1, vPageSize);

      if(messageResponse != null && messageResponse.success && messageResponse.number == 1) {
        _actualPage += 1;
        setState(() {
          _messageList = messageResponse.data.messages;
          _updateItems();
        });
      } else if(messageResponse != null && messageResponse.title != null && messageResponse.title.isNotEmpty && messageResponse.message != null && messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context, title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch(e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("loadChat\n" + e.toString());
    }
  }
  
  @protected
  Future<void> loadPage(BuildContext context, int vPageNumber) async {
    await checkToken();
    try {
      MessageResponse messageResponse = await MessageBO().getMessages(context, _user, _userTo, vPageNumber, _pageSize);

      if(messageResponse != null && messageResponse.success && messageResponse.number == 1) {
        _actualPage += 1;
        List<MessageModel> messagesLoaded = messageResponse.data.messages;
        if(messagesLoaded.isNotEmpty) {
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
        if(messagesLoaded == null || messagesLoaded.isEmpty || messagesLoaded.length < _pageSize) {
          _isLastPage = true;
        }
        
      } else if(messageResponse != null && messageResponse.title != null && messageResponse.title.isNotEmpty && messageResponse.message != null && messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context, title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch(e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("loadPage\n" + e.toString());
    }
  }
  
  @protected
  Future<void> sendMessage(String text) async {
    MessageModel message = new MessageModel(text, _user, _subject, DateUtils.currentDate());
    await checkToken();
    try {
      MessageResponse messageResponse = await MessageBO().sendMessage(context, _userTo, message);

      if(messageResponse != null && messageResponse.success && messageResponse.number == 1) {
        MessageModel sent = messageResponse.data.messageSent;

        setState(() {
          _messageList.insert(0, sent);
          _updateItems();
        });
      } else if(messageResponse != null && messageResponse.title != null && messageResponse.title.isNotEmpty && messageResponse.message != null && messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context, title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch(e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("sendMessage\n" + e.toString());
    }
  }

  Future<void> sendImageMessage(String text, File imageFile) async {
    MessageModel message = new MessageModel(text, _user, _subject, DateUtils.currentDate());
    await checkToken();
    Fluttertoast.showToast(
      msg: Translations.of(context).text('toastSendingImage'),
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    try {
      MessageResponse messageResponse = await MessageBO().sendImageMessage(context, _userTo, message, imageFile);

      if(messageResponse != null && messageResponse.success && messageResponse.number == 1) {
        MessageModel sent = messageResponse.data.messageSent;

        setState(() {
          _messageList.insert(0, sent);
          _updateItems();
        });
      } else if(messageResponse != null && messageResponse.title != null && messageResponse.title.isNotEmpty && messageResponse.message != null && messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context, title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch(e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("sendImageMessage\n" + e.toString());
    }
  }

  @protected
  Future<void> favoriteMessages(List<MessageModel> messages, bool setFavorite) async {
    await checkToken();
    try {
      MessageResponse messageResponse = await MessageBO().favoriteMessages(context, _user, messages, setFavorite);

      if(messageResponse != null && messageResponse.success && messageResponse.number == 1) {
        _messageList.forEach((f) {
          if(f.isSelected) {
            f.isFavorite = setFavorite;
            f.isSelected = false;
          }
        });
        setState(() {
          _updateItems();    
          messagesSelected = 0;            
          isSelecting = false;
        });
      } else if(messageResponse != null && messageResponse.title != null && messageResponse.title.isNotEmpty && messageResponse.message != null && messageResponse.message.isNotEmpty) {
        DialogUtils.dialog(context, title: messageResponse.title, message: messageResponse.message);
      } else {
        DialogUtils.dialog(context);
      }
    } catch(e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("favoriteMessages\n" + e.toString());
    }
  }

  void _updateItems() async {
    List<MessageModel> _messagesToShow = new List.from(_messageList);
    if(_onlyMyMessages && _onlyFavMessages) {
      _messagesToShow = _messagesToShow.where((i) => i.isFavorite).toList().where((i) => i.user.email == _user.email).toList();
    } else if(_onlyFavMessages) {
      _messagesToShow = _messagesToShow.where((i) => i.isFavorite).toList();
    } else if(_onlyMyMessages) {
      _messagesToShow = _messagesToShow.where((i) => i.user.email == _user.email).toList();
    }
    _items = new List<ListItem>();
    DateTime lastDate;
    for(var i = _messagesToShow.length - 1; i >= 0; i--) {
      if(i == _messagesToShow.length - 1) {
        String formatedDate = await DateUtils.displayDate(context, _messagesToShow[i].createDate);
        _items.insert(0, DateItem(formatedDate));
        _items.insert(0, ChatItem(_messagesToShow[i], _user, _token, this));
        lastDate = DateUtils.toDateTime(_messagesToShow[i].createDate);
      } else if(!DateUtils.compareOnlyDate(DateUtils.toDateTime(_messagesToShow[i].createDate), lastDate)) {
        String formatedDate = await DateUtils.displayDate(context, _messagesToShow[i].createDate);
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
              child: new Text(Translations.of(context).text('favoriteMessages')),
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
    if(isSelecting) {
      return new AppBar(
        backgroundColor: subjectColor,
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
              _messageList.reversed.forEach((f){
                if(f.isSelected) {
                  f.isSelected = false;
                  stringToClipboard += "${f.user.getDisplayName()}: ${StringUtils.stripTags(f.text)}\n";
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
                if(f.isSelected) {
                  listToFavorite.add(f);
                  qntSelected++;
                  if(f.isFavorite) {
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
        backgroundColor: subjectColor,
        title: new Row(
          children: <Widget>[
            new GestureDetector(
              onTap: () {
                if(_user.imageUrl != null && _user.imageUrl.isNotEmpty) {
                  Navigator.of(context).push(
                    new MaterialPageRoute(
                      settings: const RouteSettings(name: 'image-page'), 
                      builder: (context) => new ImagePage(_userTo.imageUrl, _token.webserverUrl, title: _userTo.getDisplayName(),),
                    )
                  );
                }
              },
              child: new CircleAvatar(
                backgroundColor: primaryWhite,
                backgroundImage: _ivPhoto,
              ),
            ),
            new SizedBox(
              width: 10.0,
            ),
            new Text(_userTo.getDisplayName()),
          ],
        ),
        actions: _actionAppBar(),
      );
    }
  }

  Widget _contentBody() {
    if(_items != null) {
      var chatListView = new ListView.builder(
        reverse: true,
        controller: scrollController,
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          var item = _items[index];
          if(item is DateItem) {
            return item;
          } else if(item is ChatItem) {
            return item;
          }
        },
      );
      return new Stack(
        children: <Widget>[
          chatListView,
          (!_isLoading) ? new Container() : new Container(
            height: 50.0,
            alignment: Alignment.topCenter,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: white70Transparency,
            ),
            child: new Center(child: new CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(primaryBlue),
            ),)
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
          new Text(Translations.of(context).text('loadingMessages'), style: new TextStyle(color: darkerGray),)
        ],
      ),
    );
  }

  void _onPressed() {
    if(textCtrl.text.trimRight().isNotEmpty) {
      sendMessage(textCtrl.text.trimRight());
      textCtrl.clear();
    }
  }

  Widget inputWidget(bool onChat, VoidCallback onSendPressed) {
    return new Container(
      color: onChat ? backgroundColor : primaryBlack,
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(30.0),
                color: primaryWhite,
              ),
              child: new ConstrainedBox(
                constraints: new BoxConstraints(
                  maxHeight: 100.0,
                ),
                child: new Scrollbar(
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new TextField(
                            maxLines: null,
                            controller: textCtrl,
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintText: Translations.of(context).text('chatSenderHint'),
                              hintStyle: TextStyle(color: primaryGray),
                            ),
                          ),
                        ),
                        onChat ? _cameraIcon() : new Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: new FloatingActionButton(
              mini: true,
              backgroundColor: primaryGreen,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              child: new Icon(Icons.send, color: primaryWhite,),
              onPressed: onSendPressed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async {
        if(isSelecting) {
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
        backgroundColor: backgroundColor,
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
              inputWidget(true, _onPressed),
            ],
          ),
        ),
      ),
    );
  }
}
