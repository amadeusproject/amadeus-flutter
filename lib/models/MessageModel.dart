import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';

/// Created by Vitor Martins on 23/08/18.

class MessageModel {
  MessageModel(String text, UserModel user, SubjectModel subject, String createDate) {
    this._text = text;
    this._user = user;
    this._subject = subject;
    this._createDate = createDate;
    _isFavorite = false;
  }

  MessageModel.fromJson(Map<String, dynamic> jsonMap) {
    _text = jsonMap['text'];
    _imageUrl = jsonMap['image_url'];
    _createDate = jsonMap['create_date'];
    _user = new UserModel.fromJson(jsonMap['user']);
    if(jsonMap.containsKey('subject')) {
      _subject = jsonMap['subject'] != null ? new SubjectModel.fromJson(jsonMap['subject']) : null;
    }
    _isFavorite = jsonMap['favorite'];
    _id = jsonMap['id'];
  }

  String _text, _imageUrl, _createDate;
  UserModel _user;
  SubjectModel _subject;
  bool _isFavorite, _isSelected = false;
  int _id;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'text': _text,
    'image_url': _imageUrl,
    'create_date': _createDate,
    'user': _user.toJson(),
    'subject': _subject.toJson(),
    'favorite': _isFavorite,
    'id': _id,
  };

  String get text => _text;
  set text(String value) => this._text = value;

  String get imageUrl => _imageUrl;
  set imageUrl(String value) => this._imageUrl = value;

  String get createDate => _createDate;
  set createDate(String value) => this._createDate = value;

  UserModel get user => _user;
  set user(UserModel value) => this._user = value;

  SubjectModel get subject => _subject;
  set subject(SubjectModel value) => this._subject = value;

  bool get isFavorite => _isFavorite;
  set isFavorite(bool value) => this._isFavorite = value;

  bool get isSelected => _isSelected;
  set isSelected(bool value) => this._isSelected = value;

  int get id => _id;
  set id(int value) => this._id = value;
}
