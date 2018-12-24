import 'package:flutter/material.dart';

import 'package:amadeus/res/colors.dart';

class Badge extends StatelessWidget {
  Badge({
    @required this.number,
    this.size = 20.0,
    this.padding = const EdgeInsets.all(5.0),
    this.fontSize = 10.0,
  });

  final String number;
  final EdgeInsets padding;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: padding,
      width: size,
      height: size,
      decoration: new BoxDecoration(
        color: MyColors.primaryRed,
        boxShadow: null,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: new Center(
        child: new Text(
          number,
          style: new TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
