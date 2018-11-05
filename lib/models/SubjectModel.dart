/// Created by Vitor Martins on 23/08/18.

class SubjectModel {

  String _name, _slug;
  bool _visible;
  int _notifications;
  int _pendencies;

  SubjectModel.fromJson(Map<String, dynamic> jsonMap) {
    _name = jsonMap['name'];
    _slug = jsonMap['slug'];
    _visible = jsonMap['visible'];
    _notifications = jsonMap['notifications'];
    _pendencies = jsonMap['pendencies'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': _name,
    'slug': _slug,
    'visible': _visible,
    'notifications': _notifications,
    'pendencies': _pendencies
  };

  SubjectModel(this._name, this._slug, this._visible, this._notifications);

  String get name => _name;
  set name(String name) => this._name = name;

  String get slug => _slug;
  set slug(String slug) => this._slug = slug;

  bool get visible => _visible;
  set visible(bool visible) => this._visible = visible;

  int get notifications => _notifications;
  set notifications(int notifications) => this._notifications = notifications;

  int get pendencies => _pendencies;
  set pendencies(int pendencies) => this._pendencies = pendencies;
}