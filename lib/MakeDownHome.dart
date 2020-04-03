
import 'package:flutter/material.dart';

const color1 = const Color(0xff26c586);
String value = "";

class Fourth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
        color: color1,
      child: Column (
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          Text ("I'm",
            style: TextStyle(fontSize: 60.0, color: Colors.white, fontFamily: "Signatra"),
          ),
        Text ("Down",
        style: TextStyle(fontSize: 92.0, color: Colors.white, fontFamily: "Signatra"),
      ),
          Text ("To",
            style: TextStyle(fontSize: 60.0, color: Colors.white, fontFamily: "Signatra"),
          ),
          TextField(
            onChanged: (text) {
              value = text;
            },
          )
      ]
    ));
  }
}