import 'dart:math';

import 'package:flutter/material.dart';
import 'utils/mixins.dart';

class PeoplePage extends StatefulWidget {
  PeoplePage({Key key, this.val}) : super(key: key);
  final double val;

  @override
  PeoplePageState createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> with MainPageStateMixin {

  @override
  void onPageVisible() {
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.0, // - widget.val / 3.0,
      child: Opacity(
        opacity: max(0.0, -widget.val + 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: FractionalOffset.centerRight,
              end: FractionalOffset.centerLeft,
              colors: [
                Colors.blueGrey.withOpacity(0.4),
                Colors.white,
                Colors.white,
              ],
              stops: [
                0.0,
                0.3,
                1.0,
              ]
            )
          ),
          child: Padding(
            padding: EdgeInsets.only(right: 75),
            child: Center(
              child: Transform.rotate(
                angle: widget.val * 20.0,
                child: Icon(Icons.settings, size: 100, color: Colors.grey[400],),
              ),
            ),
          ),
        ),
      ),
    );
  }
}