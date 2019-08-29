import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'utils/mixins.dart';

class BonusPage extends StatefulWidget {
  BonusPage({Key key, this.val}) : super(key: key);
  final double val;

  @override
  BonusPageState createState() => BonusPageState();
}

class BonusPageState extends State<BonusPage> with MainPageStateMixin {

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
          padding: EdgeInsets.only(right: 100),
          decoration: BoxDecoration(
            color: Colors.blue,
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
            padding: EdgeInsets.all(20.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              //SizedBox(height: 40,),
              Text("Cek Keberuntunganmu!", textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 8,),
              Text("Silakan buka tiga buah kotak di bawah ini ...", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15.0, fontStyle: FontStyle.italic, height: 1.2)),
              SizedBox(height: 12,),
              Flexible(
                child: GridView.builder(
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 20),
                  primary: true,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ScratchCard(pos: index,);
                  }
                ),
              ),
            ],),
          )
        ),
      ),
    );
  }
}

class ScratchCard extends StatefulWidget {
  ScratchCard({this.pos});
  final int pos;

  @override
  _ScratchCardState createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    return FlipCard(
        key: cardKey,
        direction: FlipDirection.HORIZONTAL, // default
        front: Card(
          margin: EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
          elevation: 8.0,
          child: Image.asset("images/icon.png"),
        ),
        back: Card(
          margin: EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
          elevation: 8.0,
          child: Center(child: Text("Back"),),
        ),
    );
  }
}