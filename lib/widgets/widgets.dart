import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

/////////////////// navs ///////////////////////////////////
class NavTitleBar extends StatefulWidget {
  NavTitleBar({this.judul, this.searchHint, this.searchController, this.onSearchTextChanged});
  final String judul;
  final String searchHint;
  final TextEditingController searchController;
  final void Function(String) onSearchTextChanged;

  @override
  _NavTitleBarState createState() => _NavTitleBarState();
}

class _NavTitleBarState extends State<NavTitleBar> with SingleTickerProviderStateMixin {
  FocusNode _searchFocusNode;
  TextEditingController _searchController;
  void Function(String) _onSearchTextChanged;
  AnimationController _searchAnimationController;
  Animation _searchAnimation;
  bool _searchBarVisible;

  @override
  void initState() {
    super.initState();
    _onSearchTextChanged = widget.onSearchTextChanged;
    _searchFocusNode = FocusNode();
    _searchController = widget.searchController ?? TextEditingController();
    _searchBarVisible = false;
    _searchAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _searchAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.bounceOut,
      //curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  _closeSearch() {
    print("PANGGIL SETSTATE = _searchBarVisible");
    setState(() { _searchBarVisible = false; });
    _searchController.text = "";
    _onSearchTextChanged("");
  }

  @override
  Widget build(BuildContext context) {
    Widget searchBar = TextField(
      controller: _searchController,
      decoration: InputDecoration(hintText: widget.searchHint, prefixIcon: Icon(Icons.search), border: InputBorder.none,),
      focusNode: _searchFocusNode,
      textInputAction: TextInputAction.search,
      onChanged: _onSearchTextChanged,
    );

    return AnimatedBuilder(
      animation: _searchAnimationController,
      builder: (BuildContext context, Widget child) {
        return Row(children: <Widget>[
          InkWell(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
              child: Row(children: <Widget>[
                Icon(Icons.chevron_left, color: Colors.black87,),
                _searchBarVisible ? Container() : SizedBox(width: 8,),
                _searchBarVisible ? Container() : Text(widget.judul, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ],),
            ),
          ),
          _searchBarVisible ? SizedBox(width: (-1 * _searchAnimation.value + 1) * 150,) : SizedBox(),
          Expanded(
            child: _searchBarVisible ? Card(
              clipBehavior: Clip.antiAlias,
              elevation: 8.0,
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 2.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),),
              child: Stack(children: <Widget>[
                Opacity(opacity: _searchAnimation.value, child: searchBar,),
                Align(alignment: Alignment.centerRight, child: Opacity(
                  opacity: _searchAnimation.value,
                  child: IconButton(
                    icon: Icon(MdiIcons.closeCircle, size: 20, color: Colors.grey,),
                    onPressed: () => _closeSearch(),
                  ),
                ),)
              ],),
            ) : Container(),
          ),
          _searchBarVisible || widget.onSearchTextChanged == null ? Container() : IconButton(
            color: Colors.black87,
            icon: Icon(Icons.search),
            tooltip: "Cari",
            onPressed: () {
              //if (_isFirstLoad) return;
              print("PANGGIL SETSTATE = _searchBarVisible");
              setState(() => _searchBarVisible = true);
              FocusScope.of(context).requestFocus(_searchFocusNode);
              _searchFocusNode.requestFocus();
              _searchAnimationController.reset();
              _searchAnimationController.forward();
            },
          ),
        ],);
      }
    );
  }
}

/////////////////// buttons ///////////////////////////////////
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
  UiButton({this.btnKey, this.color, this.icon, this.ukuranIcon, this.teks, this.aksi, this.radius = 20.0, this.elevation = 2.0, this.ukuranTeks = 0.0, this.posisiTeks = null});
  final Color color;
  final IconData icon;
  final String teks;
  final double ukuranTeks;
  final double ukuranIcon;
  final double radius;
  final double elevation;
  final Key btnKey;
  final MainAxisAlignment posisiTeks;
  final void Function() aksi;

  @override
  Widget build(BuildContext context) {
    double ukuranFont = ukuranTeks == 0.0 ? Theme.of(context).textTheme.button.fontSize : ukuranTeks;
    HSLColor warnaHSL = HSLColor.fromColor(color);
    return RaisedButton(
      key: btnKey,
      color: color,
      elevation: elevation,
      hoverElevation: elevation,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: aksi == null ? Colors.grey : warnaHSL.withLightness(0.5).toColor(), width: 2),
        borderRadius: BorderRadius.circular(radius)
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: posisiTeks ?? MainAxisAlignment.start, children: <Widget>[
        icon == null ? SizedBox() : Icon(icon, color: Colors.white, size: ukuranIcon ?? ukuranFont,),
        teks == null ? SizedBox() : Padding(padding: EdgeInsets.only(left: 8.0), child: Text(teks, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: ukuranFont),),),
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
/* class SearchBar extends StatelessWidget {
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
} */

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
