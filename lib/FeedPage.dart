import 'package:flutter/material.dart';
import './HeaderWidget.dart';

class First extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: header(context, isAppTitle: true, disappearedBackButton: true),
      body: new Container(
          child: new Center(
            child: new Icon(Icons.accessibility_new, size: 150.0, color: Colors.brown)
          )
      )
    );
  }
}