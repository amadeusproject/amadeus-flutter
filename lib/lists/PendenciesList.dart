import 'package:amadeus/models/PendencyModel.dart';

class PendenciesList {
  List<PendencyModel> _pendencies;

  void fromJson(List listMap) {
    _pendencies = new List<PendencyModel>();
    listMap.forEach((map) => _pendencies.add(new PendencyModel.fromJson(map)));
  }

  List<PendencyModel> get pendencies => _pendencies;
  set pendencies(List<PendencyModel> value) => this._pendencies = value;
}
