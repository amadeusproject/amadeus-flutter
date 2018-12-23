import 'package:flutter/material.dart';

import 'package:amadeus/res/colors.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        accentColor: subjectColor,
      ),
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new Container(
            width: 35.0,
            height: 35.0,
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.circular(17.5),
            ),
          ),
          new Container(
            width: 20.0,
            height: 20.0,
            child: new CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
