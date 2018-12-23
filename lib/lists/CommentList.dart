import 'package:amadeus/models/CommentModel.dart';

class CommentList {

  List<CommentModel> _comments;

  void fromJson(List listMap) {
    _comments = new List<CommentModel>();
    listMap.forEach((map) => _comments.add(new CommentModel.fromJson(map)));
  }

  List<CommentModel> get comments => _comments;
  set comments(List<CommentModel> comments) => this._comments = comments;
}