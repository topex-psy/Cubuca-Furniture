import 'dart:math';

import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  MenuButton({@required this.icon, @required this.teks, this.warnaIcon = Colors.red, this.ukuranIcon = 30, this.notif = 0, this.aksi});
  final IconData icon;
  final Color warnaIcon;
  final double ukuranIcon;
  final String teks;
  final int notif;
  final void Function() aksi;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Material(
        shape: CircleBorder(),
        elevation: 10,
        child: FlatButton(
          splashColor: warnaIcon.withOpacity(0.2),
          onPressed: aksi,
          padding: EdgeInsets.all(ukuranIcon / 4.0),
          shape: CircleBorder(),
          child: Column(children: <Widget>[
            Icon(icon, color: warnaIcon, size: ukuranIcon,),
            Text(teks),
          ],),
        ),
      ),
      notif > 0 ? Positioned(
        left: max(0, 6.0 + (30.0 - ukuranIcon) / 2),
        top: 0,
        child: Material(
          color: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text("$notif", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ) : SizedBox(),
    ],);
  }
}

class UiButton extends StatelessWidget {
  UiButton({this.color, this.icon, this.teks, this.aksi});
  final Color color;
  final IconData icon;
  final String teks;
  final void Function() aksi;

  @override
  Widget build(BuildContext context) {
    double ukuranTeks = Theme.of(context).textTheme.button.fontSize;
    HSLColor warnaHSL = HSLColor.fromColor(color);
    return RaisedButton(
      color: color,
      elevation: 2,
      hoverElevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: warnaHSL.withLightness(0.5).toColor(), width: 2),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(children: <Widget>[
        icon == null ? SizedBox() : Padding(padding: EdgeInsets.only(right: 8), child: Icon(icon, color: Colors.white, size: ukuranTeks,),),
        Text(teks, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: ukuranTeks),),
      ],),
      onPressed: aksi,
    );
  }
}