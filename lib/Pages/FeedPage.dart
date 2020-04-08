import 'package:flutter/material.dart';
import '../Widgets/HeaderWidget.dart';
import '../Models/Down.dart';
import '../Widgets/DownEntry.dart';

//import 'package:firebase_database/firebase_database.dart';

const color1 = const Color(0xff26c586);
//final databaseReference = FirebaseDatabase.instance.reference();
Down d1 = Down(title: "Run", creator: "Conner", nInvited: 10, nDown: 5,
    time: DateTime(2020, 4, 6, 01, 03),
    timeCreated: DateTime(2020, 4, 6, 05, 40));
 Down d2 = Down(title: "Eat", creator: "Vance", nInvited: 6, nDown: 2,
    time: DateTime(2020, 4, 7, 10, 30),
    timeCreated: DateTime(2020, 4, 6, 22, 10));
Down d3 = Down(title: "Study Brodes", creator: "Susan", nInvited: 3, nDown: 1,
    time: DateTime(2020, 4, 7, 16, 30),
    timeCreated: DateTime(2020, 4, 6, 10, 20));

List<Down> downEntries = [d1, d2, d3];

class First extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // header defines app-wide appBars
        // isAppTitle includes "appTitle" styled appropiately
        // incProfile includes the users picture as link to access profile page
        appBar: header(context, isAppTitle: true, incProfile: true),
        body: ListView.builder(
            itemBuilder: (context, index) {
              return downEntry(context, downEntries[index]);
            },
            itemCount: downEntries.length
        ),
      ),
    );
  }
}

/**
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
}**/