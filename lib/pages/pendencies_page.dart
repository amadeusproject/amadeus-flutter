import 'package:flutter/material.dart';

import 'package:amadeus/bo/PendencyBO.dart';
import 'package:amadeus/cache/TokenCacheController.dart';
import 'package:amadeus/items/PendencyItem.dart';
import 'package:amadeus/localizations.dart';
import 'package:amadeus/models/PendencyModel.dart';
import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/res/colors.dart';
import 'package:amadeus/response/PendencyResponse.dart';
import 'package:amadeus/response/TokenResponse.dart';
import 'package:amadeus/utils/DateUtils.dart';
import 'package:amadeus/utils/DialogUtils.dart';
import 'package:amadeus/utils/LogoutUtils.dart';

class PendenciesPage extends StatefulWidget {
  static String tag = 'pendencies-page';
  final SubjectModel subject;
  final UserModel userTo;
  PendenciesPage({Key key, @required this.userTo, @required this.subject}) : super(key: key);
  @override
  PendenciesPageState createState() => new PendenciesPageState(userTo, subject);
}

class PendenciesPageState extends State<PendenciesPage> {

  UserModel _user;
  SubjectModel _subject;
  List<PendencyModel> _pendencies;
  List<PendencyPageItem> _items;
  TokenResponse _token;

  PendenciesPageState(this._user, this._subject);

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

  void _updateItems() async {
    _items = new List<PendencyPageItem>();
    for(var i = _pendencies.length - 1; i >= 0; i--) {
      String formatedDate = await DateUtils.displayPendencyDate(context, _pendencies[i].date);
      _items.insert(0, DateItem(formatedDate));
      _items.insert(0, PendencyItem(_pendencies[i]));
    }
  }

  Future<void> loadPendencies() async {
    await checkToken();

    try {
      PendencyResponse pendencyResponse = await PendencyBO().getPendencies(context, _user, _subject);
      if(pendencyResponse != null) {
        if(pendencyResponse.success && pendencyResponse.number == 1) {
          _pendencies = pendencyResponse.data.pendencies;
          setState(() {
            _updateItems();
          });
        } else if(pendencyResponse.title != null && pendencyResponse.title.isNotEmpty && pendencyResponse.message != null && pendencyResponse.message.isNotEmpty) {
          DialogUtils.dialog(context, title: pendencyResponse.title, message: pendencyResponse.message);
        }
      } else {
        DialogUtils.dialog(context);
      }
    } catch (e) {
      DialogUtils.dialog(context, erro: e.toString());
      print("loadPendencies\n" + e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    loadPendencies();
  }

  Widget _contentBody() {
    if(_items != null) {
      if(_items.length == 0) {
        return new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(Translations.of(context).text('emptyPendencies'), style: new TextStyle(color: darkerGray),)
            ],
          ),
        );
      }
      return new ListView.builder(
        reverse: true,
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          var item = _items[index];
          if(item is DateItem) {
            return item;
          } else if(item is PendencyItem) {
            return item;
          }
        },
      );
    }
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
          new SizedBox(height: 5.0),
          new Text(Translations.of(context).text('loadingPendencies'), style: new TextStyle(color: darkerGray),)
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
        title: new Text((_subject != null ? _subject.name.toUpperCase() : "Null")),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.warning, color: iconsColor,),
            onPressed: null,
            disabledColor: iconsColor,
          ),
        ],
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new SizedBox(height: 5.0),
            new Flexible(
              child: _contentBody(),
            ),
          ],
        ),
      ),
    );
  }
}