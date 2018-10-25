import 'package:amadeus/models/SubjectModel.dart';

class SubjectList {

  List<SubjectModel> _subjects;

  void fromJson(Map jsonMap) {
    _subjects = new List<SubjectModel>();
    var listMap = jsonMap['subjects'];
    listMap.forEach((map) => _subjects.add(new SubjectModel.fromJson(map)));
  }

  Map toJson() {
    var list = new List();
    _subjects.forEach((model) {
      list.add(model.toJson());
    });
    Map<String, dynamic> map = <String, dynamic>{
      'subjects': list
    };
    return map;
  }

  List<SubjectModel> get subjects => _subjects;
  set subjects(List<SubjectModel> subjects) => this._subjects = subjects;

}
