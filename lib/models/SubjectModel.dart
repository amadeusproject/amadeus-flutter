/// Created by Vitor Martins on 23/08/18.

class SubjectModel {

  String _name, _slug;
  bool _visible;
  int _notifications;

  SubjectModel.fromJson(Map<String, dynamic> jsonMap) {
    _name = jsonMap['name'];
    _slug = jsonMap['slug'];
    _visible = jsonMap['visible'];
    _notifications = jsonMap['notifications'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': _name,
    'slug': _slug,
    'visible': _visible,
    'notifications': _notifications
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
}

List<SubjectModel> subjects = [
  new SubjectModel("Acústica", "Slug 1", true, 3),
  new SubjectModel("Aeronomia", "Slug 2", true, 5),
  new SubjectModel("Anatomia vegetal", "Slug 3", true, 71235),
  new SubjectModel("criação de animais", "Slug 4", true, 12),
  new SubjectModel("Desenvolvimento Social e da Personalidade", "Slug 8", true, 50),
  new SubjectModel("Ecologia dos animais domésticos e etologia", "Slug 5", true, 3000),
  new SubjectModel("Economia agrária", "Slug 6", true, 2),
  new SubjectModel("Endocrinologia", "Slug 7", true, 0),
  new SubjectModel("Estruturas de madeiras", "Slug 8", true, 800800),
  new SubjectModel("Físico-química orgânica", "Slug 6", true, 7),
  new SubjectModel("floricultura, parques e jardins", "Slug 7", true, 2006),
  new SubjectModel("Assunto 12", "Slug 8", true, 110),
];