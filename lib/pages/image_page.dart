import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

import 'package:amadeus/res/colors.dart';

class ImagePage extends StatelessWidget {
  static String tag = 'image-page';
  final String _webUrl;
  final String _imageUrl;
  final String title;
  ImagePage(this._imageUrl, this._webUrl, {this.title});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: MyColors.subjectColor,
        title: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text(title != null ? title : ""),
            new Text(title != null ? " (PERFIL)" : "", style: new TextStyle(color: MyColors.perfilColor, fontSize: 14.0)),
          ],
        ),
      ),
      body: new Container(
        child: new PhotoViewInline(
          imageProvider: new CachedNetworkImageProvider(_webUrl + _imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: 4.0,
          gaplessPlayback: true,
          backgroundColor: MyColors.backgroundColor,
        ),
      ),
    );
  }
}
