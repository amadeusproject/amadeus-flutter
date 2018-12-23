import 'package:amadeus/models/MuralModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/utils/DateUtils.dart';

class CommentModel {
  CommentModel(this._post, this._comment, this._user) {
    _createDate = DateUtils.currentDate();
  }

  CommentModel.fromJson(Map<String, dynamic> jsonMap) {
    _comment = jsonMap['comment'];
    _post = new MuralModel.fromJson(jsonMap['post']);
    _lastUpdate = jsonMap['last_update'];
    _user = new UserModel.fromJson(jsonMap['user']);
    _id = jsonMap['id'];
    _imageUrl = jsonMap['image_url'];
    _createDate = jsonMap['create_date'];
    _edited = jsonMap['edited'];
  }

  String _comment, _createDate, _lastUpdate, _imageUrl;
  MuralModel _post;
  UserModel _user;
  bool _edited;
  int _id;

  MuralModel get post => _post;
  set post(MuralModel value) => this._post = value;

  String get comment => _comment;
  set comment(String value) => this._comment = value;

  String get createDate => _createDate;
  set createDate(String value) => this._createDate = value;

  String get lastUpdate => _lastUpdate;
  set lastUpdate(String value) => this._lastUpdate = value;

  String get imageUrl => _imageUrl;
  set imageUrl(String value) => this._imageUrl = value;

  UserModel get user => _user;
  set user(UserModel value) => this._user = value;

  bool get edited => _edited;
  set edited(bool value) => this._edited = value;

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