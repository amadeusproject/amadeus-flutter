import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:amadeus/res/colors.dart';

class FavoriteButton extends StatelessWidget {
  FavoriteButton(this.isFavorite, this.onTap);

  final bool isFavorite;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new Padding(
        padding: new EdgeInsets.only(left: 6.0),
        child: new Container(
          color: Colors.white,
          height: 32.0,
          width: 32.0,
          alignment: Alignment.topCenter,
          child: new Transform.rotate(
            angle: 0.758,
            child: new Icon(
              FontAwesomeIcons.thumbtack,
              color: isFavorite ? MyColors.thumbtackActive : MyColors.thumbtackDeactive,
              size: 12.0,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
