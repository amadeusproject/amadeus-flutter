import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatelessWidget {
  static String tag = 'image-page';
  final String _webUrl;
  final String _imageUrl;
  ImagePage(this._imageUrl, this._webUrl);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(),
      backgroundColor: Colors.black,
      body: new Container(
        child: new PhotoViewInline(
          imageProvider: NetworkImage(_webUrl + _imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: 4.0,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
