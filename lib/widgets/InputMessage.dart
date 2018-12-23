import 'package:flutter/material.dart';

import 'package:amadeus/res/colors.dart';

class InputMessage extends StatelessWidget {
  InputMessage(this.textCtrl, this.onSendPressed,
      {this.showCameraIcon, this.onCameraPressed, this.placeholder = ""});

  final TextEditingController textCtrl;
  final bool showCameraIcon;
  final String placeholder;
  final Function onSendPressed;
  final Function onCameraPressed;

  Widget cameraIcon() {
    if (!(showCameraIcon ?? false)) return new Container();
    return new IconButton(
      icon: new Icon(Icons.camera_alt),
      color: MyColors.primaryGray,
      onPressed: (onCameraPressed ?? () {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: MyColors.backgroundColor,
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Container(
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.circular(30.0),
                color: Colors.white,
              ),
              child: new ConstrainedBox(
                constraints: new BoxConstraints(
                  maxHeight: 100.0,
                ),
                child: new Scrollbar(
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new TextField(
                            maxLines: null,
                            controller: textCtrl,
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintText: placeholder,
                              hintStyle: TextStyle(color: MyColors.primaryGray),
                            ),
                          ),
                        ),
                        cameraIcon(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(right: 5.0),
            child: new FloatingActionButton(
              mini: true,
              backgroundColor: MyColors.primaryGreen,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              child: new Icon(
                Icons.send,
                color: MyColors.primaryWhite,
              ),
              onPressed: onSendPressed,
            ),
          ),
        ],
      ),
    );
  }
}
