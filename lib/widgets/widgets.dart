import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/////////////////// loaders ///////////////////////////////////
class LoadingCircle extends StatelessWidget {
  LoadingCircle({this.teks = "Harap tunggu ...", this.absorb = false});
  final String teks;
  final bool absorb;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: absorb,
      child: Center(
        child: Opacity(
          opacity: 0.8,
          child: Card(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 20,
            child: Padding(padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(height: 6,),
              CircularProgressIndicator(),
              SizedBox(height: 12,),
              Text(teks),
            ],),),
          ),
        ),
      ),
    );
  }
}

/////////////////// buttons ///////////////////////////////////
class NavBackButton extends StatelessWidget {
  NavBackButton({@required this.judul});
  final String judul;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(true),
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
        child: Row(children: <Widget>[
          Icon(Icons.chevron_left, color: Colors.black87,),
          SizedBox(width: 8,),
          Text(judul, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        ],),
      ),
    );
  }
}

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
  UiButton({this.color, this.icon, this.teks, this.aksi, this.ukuranTeks = 0.0, this.posisiTeks = null});
  final Color color;
  final IconData icon;
  final String teks;
  final double ukuranTeks;
  final MainAxisAlignment posisiTeks;
  final void Function() aksi;

  @override
  Widget build(BuildContext context) {
    double ukuranFont = ukuranTeks == 0.0 ? Theme.of(context).textTheme.button.fontSize : ukuranTeks;
    HSLColor warnaHSL = HSLColor.fromColor(color);
    return RaisedButton(
      color: color,
      elevation: 2,
      hoverElevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: warnaHSL.withLightness(0.5).toColor(), width: 2),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: posisiTeks ?? MainAxisAlignment.start, children: <Widget>[
        icon == null ? SizedBox() : Padding(padding: EdgeInsets.only(right: 8), child: Icon(icon, color: Colors.white, size: ukuranFont,),),
        Text(teks, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: ukuranFont),),
      ],),
      onPressed: aksi,
    );
  }
}

class VendorCard extends StatelessWidget {
  VendorCard({@required this.logo, @required this.aksi});
  final String logo;
  final void Function() aksi;

  @override
  Widget build(BuildContext context) {
    double cardSize = 0.5 * MediaQuery.of(context).size.width / 2;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aksi,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Image.asset(logo, width: cardSize, height: cardSize, fit: BoxFit.contain,),
        ),
      ),
    );
  }
}

/////////////////// inputs ///////////////////////////////////
class SearchBar extends StatelessWidget {
  SearchBar({this.placeholder, this.controller, this.focusNode, this.onChanged});
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: placeholder, prefixIcon: Icon(Icons.search), border: InputBorder.none),
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
    );
  }
}

/////////////////// other ///////////////////////////////////
class EmptyContent extends StatelessWidget {
  EmptyContent({@required this.teks, this.icon, this.btnShow = false, this.btnTeks, this.btnColor, this.btnAksi});
  final String teks;
  final IconData icon;
  final bool btnShow;
  final String btnTeks;
  final Color btnColor;
  final void Function() btnAksi;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 24, bottom: 12), child: Icon(icon ?? Icons.face, color: Colors.grey[600], size: 100,),),
        Text(teks, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[600])),
        btnShow ? Padding(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 50),
          child: ButtonTheme(
            minWidth: 200.0,
            height: 44.0,
            child: UiButton(color: btnColor ?? Colors.greenAccent[700], teks: btnTeks, ukuranTeks: 16, posisiTeks: MainAxisAlignment.center, icon: Icons.search, aksi: btnAksi,),
          ),
        ) : SizedBox(),
        SizedBox(height: 50,),
      ],
    );
  }
}
