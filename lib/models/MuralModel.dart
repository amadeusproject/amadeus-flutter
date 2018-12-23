import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/utils/DateUtils.dart';

class MuralModel {
  MuralModel(this._post, this._action, this._user) {
    _createDate = DateUtils.currentDate();
    _favorite = false;
  }

  MuralModel.fromJson(Map<String, dynamic> jsonMap) {
    _post = jsonMap['post'];
    _lastUpdate = jsonMap['last_update'];
    _user = new UserModel.fromJson(jsonMap['user']);
    _comments = jsonMap['comments'];
    _action = jsonMap['action'];
    _id = jsonMap['id'];
    _favorite = jsonMap['favorite'];
    _imageUrl = jsonMap['image_url'];
    _createDate = jsonMap['create_date'];
    _edited = jsonMap['edited'];
  }

  String _post, _createDate, _lastUpdate, _action, _imageUrl;
  UserModel _user;
  bool _favorite, _edited;
  int _comments, _id;

  String get post => _post;
  set post(String value) => this._post = value;

  String get createDate => _createDate;
  set createDate(String value) => this._createDate = value;

  String get lastUpdate => _lastUpdate;
  set lastUpdate(String value) => this._lastUpdate = value;

  String get action => _action;
  set action(String value) => this._action = value;

  String get imageUrl => _imageUrl;
  set imageUrl(String value) => this._imageUrl = value;

  UserModel get user => _user;
  set user(UserModel value) => this._user = value;

  bool get favorite => _favorite;
  set favorite(bool value) => this._favorite = value;

  bool get edited => _edited;
  set edited(bool value) => this._edited = value;

  int get comments => _comments;
  set comments(int value) => this._comments = value;

  int get id => _id;
  set id(int value) => this._id = value;

  String getDisplayDate() {
    DateTime date = DateUtils.toDateTime(_createDate);
    String day = date.day < 10 ? "0${date.day}" : "${date.day}";
    String month = date.month < 10 ? "0${date.month}" : "${date.month}";
    String hour = date.hour < 10 ? "0${date.hour}" : "${date.hour}";
    String minute = date.minute < 10 ? "0${date.minute}" : "${date.minute}";
    return "$day/$month/${date.year} - $hour:$minute";
  }
}
