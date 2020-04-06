import 'package:flutter/material.dart';
import '../Models/Down.dart';

Widget downEntry(context, Down down) {
  return Padding(
      padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
      child: GestureDetector(
          onTap:  () {
            SnackBar snackBar = SnackBar(content: Text(down.title + " Tapped"), duration: Duration(seconds: 3));
            Scaffold.of(context).showSnackBar(snackBar);
          },
        child: Column(
        children: <Widget>[
          Text(down.title,
          style: TextStyle(
            fontSize: 30,
            color: Colors.black,
            fontWeight: FontWeight.bold
          )),
          Row(
            children: <Widget> [
              Text(down.getCleanTime(),
              style: TextStyle(
                fontSize: 25,
                color: Colors.grey
              )),
              Flexible(fit: FlexFit.tight, child: SizedBox()),
              Text(down.nInvited.toString() + " invited",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey,
                )
              )
            ]
          ),
          Row(
            children: <Widget> [
              Text(down.creator,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                )
              ),
              Flexible(fit: FlexFit.tight, child: SizedBox()),
              Text( DateTime.now().difference(down.timeCreated).inHours.toString() + " ago",
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.grey
              )),
              Flexible(fit: FlexFit.tight, child: SizedBox()),
              Text("+" + down.nDown.toString(),
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.black
              ))
            ]
          )
        ]
      ),
      )
  );
}