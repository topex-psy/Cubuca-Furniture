import 'package:cubuca_furniture/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'models/page.dart';
import 'utils/utils.dart';
import 'widgets/progress.dart';

class Page extends StatefulWidget {
  Page({Key key, this.what}) : super(key: key);
  final String what;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  bool _isLoaded = false;
  PageApi _page;

  final key = GlobalKey<ScaffoldState>();

  Future<dynamic> _getPage() async {
    return getPage(widget.what).then((page) {
      setState(() {
        _page = page;
      });
      print("DATA PAGE BERHASIL DIMUAT!");
    }).catchError((e) {
      print("DATA PAGE ERROOOOOOOOOOOOR: $e");
    }).whenComplete(() {
      print("DATA PAGE DONEEEEEEEEEEEEE!");
      setState(() {
        _isLoaded = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getPage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    h = MyHelper(context);
    a = MyAppHelper(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: key,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: HSLColor.fromColor(Colors.cyan).withLightness(0.85).toColor(),
          titleSpacing: 0.0,
          title: Row(children: <Widget>[
            NavBackButton(judul: _page?.judul ?? "Memuat ...",),
            Expanded(
              child: Container(),
            ),
          ],),
        ),
        body: SafeArea(
          child: Stack(children: <Widget>[
            _isLoaded ? SingleChildScrollView(padding: EdgeInsets.all(20), child: h.html(_page.konten),) : SizedBox(),
            Positioned.fill(child: _isLoaded ? SizedBox() : Center(child: LoadingCircle(),),),
          ],),
        ),
      ),
    );
  }
}