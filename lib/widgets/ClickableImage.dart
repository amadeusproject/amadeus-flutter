import 'package:flutter/material.dart';

import 'package:amadeus/pages/image_page.dart';

class ClickableImage extends StatelessWidget {
  final String webserverUrl, imageUrl;
  final Widget child;
  final EdgeInsets margin, padding;
  final double maxHeight;

  ClickableImage({
    @required this.webserverUrl,
    @required this.imageUrl,
    @required this.child,
    this.margin,
    this.padding,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: margin,
      padding: padding,
      child: new ConstrainedBox(
        constraints: new BoxConstraints(
          maxHeight: maxHeight,
        ),
        child: new GestureDetector(
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute(
              settings: const RouteSettings(name: 'image-page'),
              builder: (context) => new ImagePage(imageUrl, webserverUrl),
            ));
          },
        ),
      ),
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new NetworkImage(
            webserverUrl + imageUrl,
          ),
          fit: BoxFit.cover
        ),
      ),
    );
  }
}
