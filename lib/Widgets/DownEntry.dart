import 'package:flutter/material.dart';
import '../Models/Down.dart';
import '../Pages/DownEntryDetails.dart';

Widget downEntry(context, Down down, int num) {
  return Padding(
      padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
      child: GestureDetector(
          onTap:  () async {
            await Future.delayed(Duration(milliseconds: 200));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                 return new DownEntryDetails(num: num);
                },
                fullscreenDialog: true,
             ),
            );
            SnackBar snackBar = SnackBar(content: Text(down.title + " Tapped"), duration: Duration(seconds: 1));
            Scaffold.of(context).showSnackBar(snackBar);
          },
          onDoubleTap: () {
            // TODO
            // add down status to firebase
            down.isDown = !down.isDown;
            SnackBar snackBar = SnackBar(content: Text(down.isDown.toString()), duration: Duration(seconds: 1));
            Scaffold.of(context).showSnackBar(snackBar);
          },
        child: Container (
          color: down.isDown ? Theme.of(context).primaryColor : Colors.white,
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
        ),
      ),
  );
}