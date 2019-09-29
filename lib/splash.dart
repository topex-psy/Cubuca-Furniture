import 'package:flutter/material.dart';
import 'utils/constants.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _iconSize = 175.0;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () => Navigator.of(context).pop({'isStarted': true}));

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 3000),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Hero(tag: "SplashLogo", child: Image.asset(
                  "images/icon.png",
                  width: _iconSize,
                  height: _iconSize,
                  fit: BoxFit.contain,
                ),),
                SizedBox(height: 20,),
                Text(APP_NAME, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
                Text(APP_TAGLINE, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}