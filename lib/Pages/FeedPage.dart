import 'package:flutter/material.dart';
import '../Widgets/HeaderWidget.dart';
import '../Models/Down.dart';
import '../Widgets/DownEntry.dart';

import 'package:firebase_database/firebase_database.dart';

const color1 = const Color(0xff26c586);
final db = FirebaseDatabase.instance.reference().child('down');
Down d1 = Down(title: "Run", creator: "Conner", nInvited: 10, nDown: 5, isDown: false,
    time: DateTime(2020, 4, 6, 01, 03),
    timeCreated: DateTime(2020, 4, 6, 05, 40), nSeen: 6, address: "1025 N Charles St. Baltimore MD");
 Down d2 = Down(title: "Eat", creator: "Vance", nInvited: 6, nDown: 2, isDown: false,
    time: DateTime(2020, 4, 7, 10, 30),
    timeCreated: DateTime(2020, 4, 6, 22, 10), nSeen: 5);
Down d3 = Down(title: "Study Brodes", creator: "Susan", nInvited: 3, nDown: 1, isDown: false,
    time: DateTime(2020, 4, 7, 16, 30),
    timeCreated: DateTime(2020, 4, 6, 10, 20), nSeen: 2);

List<Down> downEntries = [d1, d2, d3];

class First extends StatelessWidget {

  /// Sample method for retrieving downs from Firebase
  /// Page needs to be refreshed for the data to load as reading from database is asynchronous.
  getDowns() {
    db.onChildAdded.listen((event) {
      DataSnapshot data = event.snapshot;
      Map entry = data.value;
      downEntries.add(Down(title: entry['title'], creator: "Vance", nInvited: entry['nInvited'], nDown: entry['nDown'], isDown: false,
          time: DateTime(2020, 4, 7, 10, 30),
          timeCreated: DateTime(2020, 4, 6, 22, 10)));
    });
  }

  @override
  Widget build(BuildContext context) {
    getDowns();

    return MaterialApp(
      home: Scaffold(
        // header defines app-wide appBars
        // isAppTitle includes "appTitle" styled appropiately
        // incProfile includes the users picture as link to access profile page
        appBar: header(context, isAppTitle: true, incProfile: true),
        body: ListView.builder(
            itemBuilder: (context, index) {
              return downEntry(context, downEntries[index], index);
            },
            itemCount: downEntries.length
        ),
      ),
    );
  }
}
