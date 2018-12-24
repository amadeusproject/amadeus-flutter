import 'package:flutter/material.dart';

import 'package:amadeus/widgets/Badge.dart';

class IconWithBadge extends StatelessWidget {
  IconWithBadge({
    @required this.buildContext,
    @required this.icon,
    @required this.numBadge,
    @required this.onPressCallback,
  });

  final BuildContext buildContext;
  final Icon icon;
  final int numBadge;
  final Function onPressCallback;

  @override
  Widget build(BuildContext context) {
    String number = numBadge > 99 ? "99+" : numBadge.toString();
    if (numBadge > 0) {
      return new Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          new Center(
            child: new IconButton(
              onPressed: () => onPressCallback(buildContext),
              icon: icon,
            ),
          ),
          new GestureDetector(
            onTap: () => onPressCallback(buildContext),
            child: new Badge(
              number: number,
              fontSize: 10.0,
              padding: new EdgeInsets.all(5.0),
              size: 20.0,
            ),
          ),
        ],
      );
    } else {
      return new IconButton(
        onPressed: () => onPressCallback(buildContext),
        icon: icon,
      );
    }
  }
}
