import 'package:flutter/material.dart';
import './HeaderWidget.dart';

class Second extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: header(context, isAppTitle: true, disappearedBackButton: true),
      body: new Container (
          child: new Center(
            child: new Icon(Icons.favorite, size: 150.0, color: Colors.redAccent)
          )
      )
    );
  }
}