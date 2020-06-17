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

  6/12/20:
  A thing we avoided in Down 1.0 is the removal of old downs. We would keep them all in
  the same location in Firebase, load them, but not display if they were old.
  This shouldn't be an issue if we use a constant-time space-independent data
  structure, but since we read and search linearly, high-usage users will eventually
  see pretty bad slowdown.

  As such, when we load the feed page, any downs that are considered "obsolete"
  (we define as being 12-hours past the start date) we remove from the feed.

  We store them in a new spot in firebase. User/downs-obselete. This will allow
  us to show historical data for the user, and also not delete old information.
  However, we are further doubling down on duplicated information in the
  database. Ideally, we have a table for user data. A table for down data. And a
  table for user creating down. Does Firebase being non-relational make our approach
  sound?


 */

import 'package:flutter/material.dart';
import '../Models/Down.dart';
import 'package:down/Models/User.dart';
import '../Widgets/DownEntry.dart';
import 'package:down/Pages/SettingsPage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedPage extends StatefulWidget {
  final FirebaseUser user;

  FeedPage(this.user);

  @override
  _FeedPageState createState() => _FeedPageState(this.user);
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
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
    dbUserDowns =
        FirebaseDatabase.instance.reference().child("users/${user.uid}/downs");
    dbUserDowns.onChildAdded.listen(_onDownAdded);
  }

  _onDownAdded(Event event) async {
    /*
     Note, at this point in time we have access to the database, can run
     whichever awaits for reference objects, and can populate underlying data.
      */

    DataSnapshot downInfo = await dbAllDowns.child(event.snapshot.key).once();
    /* First of three parts: Get the down from firebase and populate local
    down object with deafult data */
    Down newRecievedDown = Down.populateDown(downInfo);

    /* Second - check if the down is still relavent (its happened more than
    12 hours ago */
    if (newRecievedDown.time
        .add(new Duration(hours: 12))
        .isBefore(DateTime.now())) {
      // if it happend more than 12 hours ago
      // add down to "down-old"
      dbAllUsers
          .child(user.uid)
          .child("down-old")
          .update({newRecievedDown.id: 0});
      // remove from "downs"
      dbUserDowns.child(newRecievedDown.id).remove();

      // finally return (since we don't want to display it)
      return;
    }

    /*
      If the down is in the correct time range:

      Third, take the new down and get the user data from down. This includes:
      1) creator,
      2) invited (and whether they are down),
      3) ads associated to down (not yet implimented)
      4) (insert more as needed)
    */
    print("recieved down data: " + newRecievedDown.toString());
    DataSnapshot userInfo =
        await dbAllUsers.child(newRecievedDown.creatorID).once();
    User creator = User.populateFromDataSnapshot(userInfo, user);
    newRecievedDown.creator = creator;

    // set if this user is down in our local object
    // (we don't do it in datasnapshot because would have to pass which user)
    // TODO: could be fixed, but would have to pass the user to Models/Down.dart
    // TODO: ... or read the FirebaseAuth, but that requires a Future<void> / async
    Map downData = downInfo.value;
    newRecievedDown.isDown = downData["invited"][user.uid];

    // search invitee correct name

    /*
      TODO: Third, now that we have the correct names, pull in statuses
      TODO: Update ^, we decided to do this in DownEntryDetails
     */

    downs.add(newRecievedDown);

    downs.sort( (Down a, Down b) {
      if (a.time.isAtSameMomentAs(b.time)) {
        return 0;
      }
      // returning -1 is a comes earlier than b
      if (a.time.isBefore(DateTime.now()) == b.time.isBefore(DateTime.now())) {
        return a.time.isBefore(b.time) ?  -1 :  1;
      } else {
        return a.time.isBefore(DateTime.now()) ?  1 : -1;
      }
    });

    setState(() {
    });
  }

  Widget makeAppBar() {
    return AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Down",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Lato",
            fontSize: 45.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(user)),
              );
            },
            child: Text("Profile"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // TODO: having issues clearing the downEntry list here because runs asynchronously
    return Scaffold(
      // header defines app-wide appBars
      // isAppTitle includes "appTitle" styled appropriately
      // incProfile includes the users picture as link to access profile page
      appBar: this.makeAppBar(),
      body: downs.length == 0
          ? Center(
              child: new Text("You have no Downs. Add one now!",
                  style: Theme.of(context).textTheme.headline6))
          : ListView.builder(
              itemBuilder: (context, index) {
                if (downs[index] == null) {
                  return new Container(color: Colors.transparent);
                }
                return new DownEntry(this.user, downs[index]);
              },
              itemCount: downs.length),
    );
  }
}
