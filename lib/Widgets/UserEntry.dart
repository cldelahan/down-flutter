import 'package:flutter/material.dart';
import '../Models/User.dart';

Widget userEntry(context, User user, int num) {
  return Padding(
      padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
      child: Container(
        color: Colors.white,
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            Container(
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill, image: new NetworkImage(user.url)))),
            SizedBox(width: 10.0),
            Text(user.profileName,
                style: TextStyle(
                    fontSize: 20, color: Colors.black, fontFamily: "Lato")),
          ]),
          Row(children: <Widget>[
            SizedBox(height: 50.0, width: 20.0,),
            Flexible(
              child: Text("This is a temporary status hardcoded in and can wrap. Isn't that neat!",
                style: TextStyle(
                    fontSize: 20, color: Colors.black, fontFamily: "Lato"))
            )
          ]),
          Row(children: <Widget>[
            Flexible(fit: FlexFit.tight, child: SizedBox()),
            Text("4",
              style: TextStyle(
                fontSize: 20, color: Colors.black, fontFamily: "Lato"
              )
            ),
            Container(
              child: Icon(Icons.arrow_drop_up, color: Colors.black, size:30.0),
              alignment: Alignment.bottomRight,
            )
          ]
          )
        ]),
      ));
}
