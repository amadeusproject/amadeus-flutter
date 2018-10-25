import 'package:amadeus/models/SubjectModel.dart';
import 'package:amadeus/models/UserModel.dart';

/// Created by Vitor Martins on 23/08/18.

class MessageModel {

  String _text, _imageUrl, _createDate;
  UserModel _user;
  SubjectModel _subject;
  bool _isFavorite, _isSelected = false;
  int _id;

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
  set text(String text) => this._text = text;

  String get imageUrl => _imageUrl;
  set imageUrl(String imageUrl) => this._imageUrl = imageUrl;

  String get createDate => _createDate;
  set createDate(String createDate) => this._createDate = createDate;

  UserModel get user => _user;
  set user(UserModel user) => this._user = user;

  SubjectModel get subject => _subject;
  set subject(SubjectModel subject) => this._subject = subject;

  bool get isFavorite => _isFavorite;
  set isFavorite(bool isFavorite) => this._isFavorite = isFavorite;

  bool get isSelected => _isSelected;
  set isSelected(bool isSelected) => this._isSelected = isSelected;

  int get id => _id;
  set id(int id) => this._id = id;
}
