import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: true,
        transitionBetweenRoutes: true,
        previousPageTitle: 'My Eagle Card',
        //heroTag: 'bar',
      ),
      child: Hero(
        tag: 'Schedule',
        child: PhotoView(
          maxScale: 1.25,
          minScale: .25,
          imageProvider: CachedNetworkImageProvider(
            "https://github.com/jawshoeadan/flutter_digipass/raw/master/assets/Schedule.png",
          ),
        ),
      ),
    );
  }
}
