/// Created by Vitor Martins on 28/10/18.

class PendencyModel {
  PendencyModel.fromJson(Map<String, dynamic> jsonMap) {
    _date = jsonMap['str_date'];
    _pendencies = jsonMap['total'];
  }

  String _date;
  int _pendencies;

  String get date => _date;
  set date(String value) => this._date = value;

  int get pendencies => _pendencies;
  set pendencies(int value) => this._pendencies = value;
}
