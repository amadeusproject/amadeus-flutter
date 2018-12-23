import 'package:amadeus/models/MuralModel.dart';

class MuralList {
  List<MuralModel> _posts;

  void fromJson(List listMap) {
    _posts = new List<MuralModel>();
    listMap.forEach((map) => _posts.add(new MuralModel.fromJson(map)));
  }

  List<MuralModel> get posts => _posts;
  set posts(List<MuralModel> value) => this._posts = value;
}
