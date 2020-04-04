import 'package:flutter/material.dart';
import './HeaderWidget.dart';

class Third extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, isAppTitle: false, strTitle: "Friends"),
        body: Container(
            child: new Center (
                child: new Icon(
                    Icons.local_pizza, size: 150.0, color: Colors.teal)
            )
        )
    );
  }
}