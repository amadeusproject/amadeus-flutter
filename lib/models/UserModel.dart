/// Created by Vitor Martins on 23/08/18.

class UserModel {

  String _email, _socialName, _username, _lastName, _imageUrl, _description, _lastUpdate, _dateCreated;
  bool _isStaff, _isActive;
  int _unseenMsgs;

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
  set email(String email) => this._email = email;

  String get socialName => _socialName;
  set socialName(String socialName) => this._socialName = socialName;

  String get username => _username;
  set username(String username) => this._username = username;

  String get lastName => _lastName;
  set lastName(String lastName) => this._lastName = lastName;
  
  String get imageUrl => _imageUrl;
  set imageUrl(String imageUrl) => this._imageUrl = imageUrl;
  
  String get description => _description;
  set description(String description) => this._description = description;
    
  String get lastUpdate => _lastUpdate;
  set lastUpdate(String lastUpdate) => this._lastUpdate = lastUpdate;
    
  String get dateCreated => _dateCreated;
  set dateCreated(String dateCreated) => this._dateCreated = dateCreated;

  bool get isStaff => _isStaff;
  set isStaff(bool isStaff) => this._isStaff = isStaff;

  bool get isActive => _isActive;
  set isActive(bool isActive) => this._isActive = isActive;

  int get unseenMsgs => _unseenMsgs;
  set unseenMsgs(int unseenMsgs) => this._unseenMsgs = unseenMsgs;

  String getDisplayName() {
    if (socialName == null || socialName.isEmpty) {
      return "$username $lastName";
    }
    return socialName;
  }
}