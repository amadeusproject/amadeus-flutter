import 'package:amadeus/models/UserModel.dart';

class ParticipantsList {

  List<UserModel> _participants;

  void fromJson(Map jsonMap) {
    _participants = new List<UserModel>();
    var listMap = jsonMap['participants'];
    listMap.forEach((map) => _participants.add(
      new UserModel.fromJson(map))
    );
  }

  List<UserModel> get participants => _participants;
  set participants(List<UserModel> participants) => this._participants = participants;
  
}
