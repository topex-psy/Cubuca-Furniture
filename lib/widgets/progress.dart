import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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