import 'package:cubuca_furniture/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'utils/utils.dart';
import 'widgets/progress.dart';

class FAQ extends StatefulWidget {
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  final key = GlobalKey<ScaffoldState>();
  bool _isLoaded = true;

  @override
  void initState() {
    super.initState();
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
            NavBackButton(judul: "FAQ",),
            Expanded(
              child: Container(),
            ),
          ],),
        ),
        body: SafeArea(
          child: Stack(children: <Widget>[
            _isLoaded ? SingleChildScrollView(padding: EdgeInsets.all(20), child: Container(),) : SizedBox(),
            Positioned.fill(child: _isLoaded ? SizedBox() : Center(child: LoadingCircle(),),),
          ],),
        ),
      ),
    );
  }
}