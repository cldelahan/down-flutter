/*
  Author: Conner Delahanty

  Code creates a listener for Firebase, and reacts when new Downs come in +
  displays them here.

  Notes:
  This currently requires passing the FirebaseUser user object to the class. We instead
  can use the FirebaseAuth.instance.getCurrentUser() function. However that is async.
  It can only be used in the listener then, but that would require setting our dbUserDowns
  DB reference to the user root - making it trigger on a lot of data that isn't new downs
  (such as other users new downs and creating new users)

  Because of this, I pass the FirebaseUser user object, although it is a bit sloppy

 */

import 'package:flutter/material.dart';
import '../Widgets/HeaderWidget.dart';
import '../Models/Down.dart';
import '../Widgets/DownEntry.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/*Down d1 = Down(title: "Run", creator: "Conner", nInvited: 10, nDown: 5, isDown: false,
    time: DateTime(2020, 4, 6, 01, 03),
    timeCreated: DateTime(2020, 4, 6, 05, 40), nSeen: 6, address: "1025 N Charles St. Baltimore MD");
 Down d2 = Down(title: "Eat", creator: "Vance", nInvited: 6, nDown: 2, isDown: false,
    time: DateTime(2020, 4, 7, 10, 30),
    timeCreated: DateTime(2020, 4, 6, 22, 10), nSeen: 5);
Down d3 = Down(title: "Study Brodes", creator: "Susan", nInvited: 3, nDown: 1, isDown: false,
    time: DateTime(2020, 4, 7, 16, 30),
    timeCreated: DateTime(2020, 4, 6, 10, 20), nSeen: 2);*/


class FeedPage extends StatefulWidget {
  final FirebaseUser user;
  FeedPage(this.user);

  @override
  _FeedPageState createState() => _FeedPageState(this.user);

}

class _FeedPageState extends State<FeedPage> with AutomaticKeepAliveClientMixin{

  FirebaseUser user;
  List<Down> downs = [];
  DatabaseReference dbAllDowns;
  DatabaseReference dbAllUsers;
  DatabaseReference dbUserDowns;
  bool wantKeepAlive = true;

  _FeedPageState(this.user);

  @override
  void initState() {
    super.initState();
    print("Initializing feed page");
    dbAllDowns = FirebaseDatabase.instance.reference().child("down");
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");
    dbUserDowns = FirebaseDatabase.instance
      .reference()
      .child("users/${user.uid}/downs");
    dbUserDowns.onChildAdded.listen(_onDownAdded);
  }

  _onDownAdded(Event event) async {
    /*
     Note, at this point in time we have access to the database, can run
     whichever awaits for reference objects, and can populate underlying data.

     To front the uploading costs up front, we choose to populate, for each
     visible down, the Down data, the data about the users in the down, and the
     data about the statuses with the down. This may take an extra second here,
     but is much faster than having the app run slow every minor transition.

     We can hide this operation behind a "loading spinning wheel" upon entering
     the app. Notice, this only needs done once and for each new down because
     this state extends AutomaticKeepAliveClient, which perserves the values
     of this state when they switch tabs (but will still update on new down
     because of above listener).
      */

    print(event.snapshot.key);
    print(event.snapshot.value);
    DataSnapshot downInfo = await dbAllDowns.child(event.snapshot.key).once();
    /* First of three parts: Get the down from firebase and populate local
    down object with deafult data */
    Down newRecievedDown = Down.populateDown(downInfo);

    /*
      Second, take the new down and get the user data from down. This includes:
      1) creator,
      2) invited (and whether they are down),
      3) ads associated to down (not yet implimented)
      4) (insert more as needed)
    */
    print("recieved down data: " + newRecievedDown.toString());
    DataSnapshot userInfo = await dbAllUsers.child(newRecievedDown.creatorID).once();
    Map userData = userInfo.value;

    // search creator correct name
    newRecievedDown.creator = userData["profileName"];
    newRecievedDown.creatorUrl = userData["url"];

    Map downData = downInfo.value;

    print("Here: " + downData["invited"].toString());
    print("Here Next: " + downData["invited"][user.uid].toString());
    newRecievedDown.isDown = downData["invited"][user.uid] == 1 ? true : false;

    // search invitee correct name

    /*
      TODO: Third, now that we have the correct names, pull in statuses
     */


    print(downInfo.value.toString());
    setState(() {
      downs.add(newRecievedDown);
      //downs.add(Down.populateDown(downInfo));
    });
    print("Added down");
    print(downInfo.toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: having issues clearing the downEntry list here because runs asynchronously
    return Scaffold(
        // header defines app-wide appBars
        // isAppTitle includes "appTitle" styled appropriately
        // incProfile includes the users picture as link to access profile page
        appBar: header(context, isAppTitle: true, incProfile: true),
        body: ListView.builder(
            itemBuilder: (context, index) {
              if (downs[index] == null) {
                return new Container(color: Colors.transparent);
              }
              return new DownEntry(downs[index]);
            },
            itemCount: downs.length
        ),
    );
  }
}
