/// Created by Vitor Martins on 23/08/18.

class SubjectModel {
  SubjectModel(this._name, this._slug, this._visible, this._notifications);

  SubjectModel.fromJson(Map<String, dynamic> jsonMap) {
    _name = jsonMap['name'];
    _slug = jsonMap['slug'];
    _visible = jsonMap['visible'];
    _notifications = jsonMap['notifications'];
    _pendencies = jsonMap['pendencies'];
    _muralNotifications = jsonMap['mural'];
  }

  String _name, _slug;
  bool _visible;
  int _notifications;
  int _pendencies;
  int _muralNotifications;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': _name,
    'slug': _slug,
    'visible': _visible,
    'notifications': _notifications,
    'pendencies': _pendencies,
    'mural': _muralNotifications
  };

  String get name => _name;
  set name(String value) => this._name = value;

  String get slug => _slug;
  set slug(String value) => this._slug = value;

  bool get visible => _visible;
  set visible(bool value) => this._visible = value;

  int get notifications => _notifications;
  set notifications(int value) => this._notifications = value;

  int get pendencies => _pendencies;
  set pendencies(int value) => this._pendencies = value;

  int get muralNotifications => _muralNotifications;
  set muralNotifications(int value) => this._muralNotifications = value;
}
