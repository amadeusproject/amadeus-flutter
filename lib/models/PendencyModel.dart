/// Created by Vitor Martins on 28/10/18.

class PendencyModel {

  String _date;
  int _pendencies;

  PendencyModel.fromJson(Map<String, dynamic> jsonMap) {
    _date = jsonMap['str_date'];
    _pendencies = jsonMap['total'];
  }

  String get date => _date;
  set date(String date) => this._date = date;

  int get pendencies => _pendencies;
  set pendencies(int pendencies) => this._pendencies = pendencies;
}
