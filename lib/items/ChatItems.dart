import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:amadeus/models/MessageModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/pages/chat_page.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/DateUtils.dart';
import 'package:amadeus/utils/StringUtils.dart';
import 'package:amadeus/widgets/ClickableImage.dart';

abstract class ListItem {}

class DateItem extends StatelessWidget implements ListItem {

  final String dateToShow;

  DateItem(this.dateToShow);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Container(
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(4.0),
          color: MyColors.dateBackground,
        ),
        padding: EdgeInsets.all(5.0),
        child: new Text(
          dateToShow,
          style: new TextStyle(
            color: MyColors.dateFontColor,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget implements ListItem {

  final UserModel _user;
  final MessageModel _msg;
  final TokenResponse _token;
  final ChatPageState parent;

  ChatItem(this._msg, this._user, this._token, this.parent);

  Widget _messageText(String text) {
    if(text.isNotEmpty) {
      return new Text(text);
    }
    return new Container(
      constraints: const BoxConstraints(
        maxWidth: 0.0,
        maxHeight: 0.0,
      ),
    );
  }

  Widget _imageWidget(BuildContext context) {
    if(_msg.imageUrl != null && _msg.imageUrl.isNotEmpty) {
      return new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
          new ClickableImage(
            webserverUrl: _token.webserverUrl,
            imageUrl: _msg.imageUrl,
            padding: new EdgeInsets.symmetric(vertical: 5.0),
            maxHeight: 350.0,
          ),
        ],
      );
    }
    return new Container(
      width: 0.0,
      height: 0.0,
    );
  }

  Widget _messageInfo() {
    Widget _text = new Text(
      DateUtils.getHour(_msg.createDate),
      style: new TextStyle(
        fontSize: 10.0,
        color: MyColors.darkerGray,
      ),
      textAlign: TextAlign.right,
    );
    if(_msg.isFavorite) {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _text,
          new SizedBox(width: 5.0),
          new Icon(FontAwesomeIcons.thumbtack,
            color: MyColors.darkerGray,
            size: 10.0,
          ),
        ],
      );
    } else {
      return _text;
    }
  }

  void _setSelection(BuildContext context) {
    _msg.isSelected = !_msg.isSelected;
    parent.updateSelectedMessages(_msg.isSelected);
  }

  Color _chooseColor() {
    if(_msg.isSelected && _msg.user.email == _user.email) {
      return MyColors.myMessageSelected;
    } else if (_msg.isSelected) {
      return MyColors.otherMessageSelected;
    } else if (_msg.user.email == _user.email) {
      return MyColors.myMessage;
    } else {
      return MyColors.otherMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        if(parent.isSelecting) {
          _setSelection(context);
        }
      },
      onLongPress: () {
        if(!parent.isSelecting) {
          parent.isSelecting = true;
        }
        _setSelection(context);
      },
      child: new Container(
        color: _msg.isSelected ? MyColors.selectedBlue : Colors.transparent,
        child: new Padding(
          padding: EdgeInsets.all(5.0),
          child: new Column(
            crossAxisAlignment: (_msg.user.email == _user.email ? CrossAxisAlignment.end : CrossAxisAlignment.start),
            children: <Widget>[
              new Container(
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(4.0),
                  color: _chooseColor(),
                ),
                padding: EdgeInsets.all(5.0),
                child: new ConstrainedBox(
                  constraints: new BoxConstraints(
                    maxWidth: 350.0,
                    minWidth: 60.0,
                  ),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _messageText(StringUtils.stripTags(_msg.text)),
                      _imageWidget(context),
                      _messageInfo(),
                    ], 
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}