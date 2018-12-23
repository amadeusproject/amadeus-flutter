/// Created by Vitor Martins on 23/08/18.

class UserModel {
  UserModel.fromJson(Map<String, dynamic> jsonMap) {
    _email = jsonMap['email'];
    _socialName = jsonMap['social_name'];
    _username = jsonMap['username'];
    _lastName = jsonMap['last_name'];
    _imageUrl = jsonMap['image_url'];
    _description = jsonMap['description'];
    _lastUpdate = jsonMap['last_update'];
    _dateCreated = jsonMap['date_created'];
    _isStaff = jsonMap['is_staff'];
    _isActive = jsonMap['is_active'];
    _unseenMsgs = jsonMap['unseen_msgs'];
  }

  String _email,
      _socialName,
      _username,
      _lastName,
      _imageUrl,
      _description,
      _lastUpdate,
      _dateCreated;
  bool _isStaff, _isActive;
  int _unseenMsgs;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'username': username,
    'email': email,
    'image_url': imageUrl,
    'last_update': lastUpdate,
    'date_created': dateCreated,
    'last_name': lastName,
    'social_name': socialName,
    'is_staff': isStaff,
    'is_active': isActive,
    'description': description,
    'unseen_msgs': unseenMsgs
  };

  String get email => _email;
  set email(String value) => this._email = value;

  String get socialName => _socialName;
  set socialName(String value) => this._socialName = value;

  String get username => _username;
  set username(String value) => this._username = value;

  String get lastName => _lastName;
  set lastName(String value) => this._lastName = value;

  String get imageUrl => _imageUrl;
  set imageUrl(String value) => this._imageUrl = value;

  String get description => _description;
  set description(String value) => this._description = value;

  String get lastUpdate => _lastUpdate;
  set lastUpdate(String value) => this._lastUpdate = value;

  String get dateCreated => _dateCreated;
  set dateCreated(String value) => this._dateCreated = value;

  bool get isStaff => _isStaff;
  set isStaff(bool value) => this._isStaff = value;

  bool get isActive => _isActive;
  set isActive(bool value) => this._isActive = value;

  int get unseenMsgs => _unseenMsgs;
  set unseenMsgs(int value) => this._unseenMsgs = value;

  String getDisplayName() {
    if (socialName == null || socialName.isEmpty) {
      return "$username $lastName";
    }
    return socialName;
  }
}
