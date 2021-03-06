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
          imageProvider: AssetImage("assets/Schedule.png"),
        ),
      ),
    );
  }
}