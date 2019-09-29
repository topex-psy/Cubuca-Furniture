import 'dart:math';

import 'package:flutter/material.dart';
import 'utils/mixins.dart';
import 'widgets/widgets.dart';

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
          padding: EdgeInsets.only(right: 75),
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
          /* child: Center(
            child: Transform.rotate(
              angle: widget.val * 20.0,
              child: Icon(Icons.settings, size: 100, color: Colors.grey[400],),
            ),
          ), */
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Stack(children: <Widget>[
              Positioned(
                left: 0,
                top: 30,
                child: Transform(
                  transform: Matrix4.identity()
                    ..rotateZ(widget.val * 1.25)
                    ..translate(widget.val * -5.0),
                  child: Icon(Icons.search, size: 200, color: Colors.grey[350],),
                ),
              ),
              Transform.translate(
                offset: Offset(0, widget.val * -150),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  SizedBox(height: 30,),
                  Text("Butuh sesuatu?", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                  SizedBox(height: 12,),
                  Card(
                    elevation: 8.0,
                    child: TextField(
                      //controller: controller,
                      decoration: InputDecoration(hintText: "Cari sesuatu ...", prefixIcon: Icon(Icons.search), border: InputBorder.none),
                      //focusNode: focusNode,
                      textInputAction: TextInputAction.search,
                      //onChanged: onChanged,
                    ),
                  ),
                ],)
              ),
            ],),
          )
        ),
      ),
    );
  }
}