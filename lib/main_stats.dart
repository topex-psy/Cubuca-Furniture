import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'utils/mixins.dart';
import 'utils/utils.dart';
import 'bantuan.dart';
import 'faq.dart';
import 'page.dart';

class StatsPage extends StatefulWidget {
  StatsPage({Key key, this.val}) : super(key: key);
  final double val;

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> with MainPageStateMixin {
  @override
  void onPageVisible() {
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listMenu = [
      ListMenuDrawer(Icons.rate_review, "Beri Rating", () {
        LaunchReview.launch();
      }),
      ListMenuDrawer(Icons.info, "Tentang Kami", () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Page(what: "about",)));
      }),
      ListMenuDrawer(Icons.bookmark, "Syarat & Privasi", () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Page(what: "terms",)));
      }),
      //ListMenuDrawer(Icons.people, "Jadi Mitra", () {}),
      ListMenuDrawer(Icons.phone_in_talk, "Kontak Kami", () {
        h.kontakKami();
      }),
      Divider(color: Colors.grey[200],),
      ListMenuDrawer(Icons.question_answer, "FAQ", () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FAQ()));
      }),
      ListMenuDrawer(Icons.help, "Bantuan", () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Bantuan()));
      }),
    ];
    int offset = 0;

    return Transform.translate(
      offset: Offset((widget.val + 1.0) * 120.0, 0.0),
      child: Material(
        elevation: 20,
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: FractionalOffset.centerRight,
              end: FractionalOffset.centerLeft,
              colors: [
                Colors.blueGrey.withOpacity(0.2),
                Colors.white,
                Colors.white,
              ],
              stops: [
                0.0,
                0.3,
                1.0,
              ]
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 24, bottom: 8, left: 22, right: 22),
                  child: Text("Perlu Bantuan?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: ListBody(
                      children: listMenu.map((Widget w) {
                        offset -= w is Divider ? 50 : 100;
                        return Transform.translate(offset: Offset(widget.val * offset, 0), child: Opacity(opacity: max(0.0, 1.0 + widget.val), child: w));
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}