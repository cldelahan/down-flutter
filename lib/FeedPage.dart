import 'package:flutter/material.dart';
import './HeaderWidget.dart';

const color1 = const Color(0xff26c586);

class First extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true, disappearedBackButton: true),
      body: Stack(
        children: <Widget>[
          Container(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                //down('run', 'conner', '12:12 a' ),
                down('run','conner', 'assets/person1.jpg'),
                down('run', 'conner', 'assets/person1.jpg'),
                down('run', 'conner', 'assets/person1.jpg'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


Widget down(String dName, String uName, image) {
  return Padding(
    padding: const EdgeInsets.only(right: 17),
    child: Container(
      constraints: BoxConstraints.tightForFinite(
        width: 100,
        height: 100,
      ),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              dName,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              uName,
            )
          ],
        ),
      ),
    )
  );
}