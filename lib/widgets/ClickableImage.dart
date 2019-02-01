import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:amadeus/pages/image_page.dart';

class ClickableImage extends StatelessWidget {
  final String webserverUrl, imageUrl;
  final EdgeInsets margin, padding;
  final BorderRadiusGeometry borderRadius;
  final double maxHeight;

  ClickableImage({
    @required this.webserverUrl,
    @required this.imageUrl,
    this.margin,
    this.padding,
    this.borderRadius,
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
        borderRadius: borderRadius,
        image: new DecorationImage(
          image: new CachedNetworkImageProvider(webserverUrl + imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          new BoxShadow(
            color: Colors.grey,
            blurRadius: 2.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
    );
  }
}
