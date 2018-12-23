import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/utils/DateUtils.dart';

class MuralModel {

  String _post, _createDate, _lastUpdate, _action, _imageUrl;
  UserModel _user;
  bool _favorite, _edited;
  int _comments, _id;

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

  String get post => _post;
  set post(String post) => this._post = post;

  String get createDate => _createDate;
  set createDate(String createDate) => this._createDate = createDate;

  String get lastUpdate => _lastUpdate;
  set lastUpdate(String lastUpdate) => this._lastUpdate = lastUpdate;

  String get action => _action;
  set action(String action) => this._action = action;

  String get imageUrl => _imageUrl;
  set imageUrl(String imageUrl) => this._imageUrl = imageUrl;

  UserModel get user => _user;
  set user(UserModel user) => this._user = user;

  bool get favorite => _favorite;
  set favorite(bool favorite) => this._favorite = favorite;

  bool get edited => _edited;
  set edited(bool edited) => this._edited = edited;

  int get comments => _comments;
  set comments(int comments) => this._comments = comments;

  int get id => _id;
  set id(int id) => this._id = id;

  String getDisplayDate() {
    DateTime date = DateUtils.toDateTime(_createDate);
    String day = date.day < 10 ? "0${date.day}" : "${date.day}";
    String month = date.month < 10 ? "0${date.month}" : "${date.month}";
    String hour = date.hour < 10 ? "0${date.hour}" : "${date.hour}";
    String minute = date.minute < 10 ? "0${date.minute}" : "${date.minute}";
    return "$day/$month/${date.year} - $hour:$minute";
  }
}