import 'package:amadeus/models/MuralModel.dart';
import 'package:amadeus/models/UserModel.dart';
import 'package:amadeus/utils/DateUtils.dart';

class CommentModel {

  String _comment, _createDate, _lastUpdate, _imageUrl;
  MuralModel _post;
  UserModel _user;
  bool _edited;
  int _id;

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

  MuralModel get post => _post;
  set post(MuralModel post) => this._post = post;

  String get comment => _comment;
  set comment(String comment) => this._comment = comment;

  String get createDate => _createDate;
  set createDate(String createDate) => this._createDate = createDate;

  String get lastUpdate => _lastUpdate;
  set lastUpdate(String lastUpdate) => this._lastUpdate = lastUpdate;

  String get imageUrl => _imageUrl;
  set imageUrl(String imageUrl) => this._imageUrl = imageUrl;

  UserModel get user => _user;
  set user(UserModel user) => this._user = user;

  bool get edited => _edited;
  set edited(bool edited) => this._edited = edited;

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