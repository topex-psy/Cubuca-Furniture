import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fireworks/fireworks.dart';
import 'package:flip_card/flip_card.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'utils/mixins.dart';

const int maxTileToFlip = 3;
const int tileCount = 6;

class BonusPage extends StatefulWidget {
  BonusPage({Key key, this.val}) : super(key: key);
  final double val;

  @override
  BonusPageState createState() => BonusPageState();
}

class BonusPageState extends State<BonusPage> with MainPageStateMixin {
  int _flippedTile = 0;

  @override
  void onPageVisible() {
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
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
          child: Stack(alignment: AlignmentDirectional.center, children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Text("Cek Keberuntunganmu!", textAlign: TextAlign.center, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 8,),
                Text("Silakan pilih tiga kotak yang ingin Anda buka ...", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15.0, fontStyle: FontStyle.italic, height: 1.2)),
                SizedBox(height: 12,),
                Flexible(
                  child: GridView.builder(
                    itemCount: tileCount,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 20),
                    primary: true,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      double offsetX = 0.0;
                      double offsetY = 0.0;
                      switch (index) {
                        case 0:
                          offsetX = 0.0 + widget.val * 75.0;
                          offsetY = 0.0 + widget.val * 125.0;
                          break;
                        case 1:
                          offsetX = 0.0 - widget.val * 75.0;
                          offsetY = 0.0 + widget.val * 125.0;
                          break;
                        case 2:
                          offsetX = 0.0 + widget.val * 50.0;
                          break;
                        case 3:
                          offsetX = 0.0 - widget.val * 50.0;
                          break;
                        case 4:
                          offsetX = 0.0 + widget.val * 75.0;
                          offsetY = 0.0 - widget.val * 125.0;
                          break;
                        case 5:
                          offsetX = 0.0 - widget.val * 75.0;
                          offsetY = 0.0 - widget.val * 125.0;
                          break;
                      }
                      return Transform.translate(
                        offset: Offset(offsetX, offsetY),
                        child: TileCard(pos: index, isDisabled: _flippedTile == maxTileToFlip, aksi: () {
                          setState(() {
                            _flippedTile++;
                            if (_flippedTile == maxTileToFlip) {
                              //TODO fireworks
                            }
                          });
                        },),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20,),
                Text("Kesempatan hari ini: "),
                Text("${(maxTileToFlip - _flippedTile)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
              ],),
            ),
            _flippedTile == maxTileToFlip ? Padding(padding: EdgeInsets.symmetric(vertical: 100), child: Fireworks(
              maxHeight: 200,
              numberOfExplosions: 2,
            ),) : Container(),
          ],)
        ),
    );
  }
}

class TileCard extends StatefulWidget {
  TileCard({this.pos, this.isDisabled = false, this.aksi});
  final int pos;
  final bool isDisabled;
  final void Function() aksi;

  @override
  _TileCardState createState() => _TileCardState();
}

class _TileCardState extends State<TileCard> {
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  bool _isFlipped;
  
  @override
  void initState() {
    super.initState();
    _isFlipped = false;
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      key: cardKey,
      direction: FlipDirection.HORIZONTAL,
      flipOnTouch: !_isFlipped && !widget.isDisabled,
      onFlip: () {
        setState(() { _isFlipped = true; });
        widget.aksi();
      },
      front: Opacity(
        opacity: widget.isDisabled ? 0.5 : 1.0,
        child: Card(
          margin: EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
          elevation: 8.0,
          color: Colors.blueGrey,
          child: Center(child: Text("?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 60, color: Colors.blueGrey[400]),),),
        ),
      ),
      back: Card(
        margin: EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(35)),
        elevation: 8.0,
        child: Center(
          child: widget.pos % 2 == 0 ? Image.asset("images/icon.png") : Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Icon(MdiIcons.face, color: Colors.lightBlue, size: 40.0,),
            SizedBox(height: 4,),
            Text("Coba lagi", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.lightBlue),),
          ],),
        ),
      ),
    );
  }
}