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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:down/Models/Down.dart';
import 'package:down/Models/SponsoredDown.dart';
import 'package:down/Widgets/DownEntry.dart';
import 'package:down/Pages/FeedbackPage.dart';
import 'package:down/Widgets/SponsoredDownEntry.dart';
import 'package:down/Pages/SettingsPage.dart';

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
  List<SponsoredDown> sponsoredDowns = [];

  DatabaseReference dbUserDowns;
  DatabaseReference dbAllDowns;
  DatabaseReference dbAllSponsoredDowns;
  DatabaseReference dbUserSubscriptions;

  bool wantKeepAlive = true;

  _FeedPageState(this.user);

  @override
  void initState() {
    super.initState();
    dbUserDowns =
        FirebaseDatabase.instance.reference().child("users/${user.uid}/downs");
    dbAllDowns = FirebaseDatabase.instance.reference().child("down");
    dbAllSponsoredDowns =
        FirebaseDatabase.instance.reference().child("sponsored/downs");
    dbUserSubscriptions = FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/subscribed");
    // Assign listeners for if there are new downs
    // ... or if there are new subscriptions
    dbUserDowns.onChildAdded.listen(_onDownAdded);
    dbUserDowns.onChildRemoved.listen(_onDownDeleted);
    dbUserSubscriptions.onChildAdded.listen(_getSubscriptions);
  }

  _onDownAdded(Event event) async {
    // Get data about down from other side of database
    DataSnapshot downInfo = await dbAllDowns.child(event.snapshot.key).once();
    // Populate down from Down Populator
    Down newRecievedDown = await Down.populateDown(downInfo);
    if (!newRecievedDown.shouldDisplayDown()) {
      // Down is too old to display - move to down-old
      FirebaseDatabase.instance
          .reference()
          .child("users")
          .child(user.uid)
          .child("down-old")
          .update({newRecievedDown.id: 0});
      dbUserDowns.child(newRecievedDown.id).remove();
      return;
    }
    // Add Down to list of Downs
    downs.add(newRecievedDown);
    // Sort down to get good ordering (sort is in Down.compareTo)
    downs.sort();
    if (this.mounted) {
      setState(() {});
    }
  }

  _onDownDeleted(Event event) {

    // Have to search through because we get the UID
    // and deletion requires the index or object
    // Other option requires loading another Down, but would be
    // expensive.
    for (int i = 0; i < downs.length; i++) {
      if (this.downs.elementAt(i).id == event.snapshot.key) {
        this.downs.removeAt(i);
        break;
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  _getSubscriptions(Event event) async {
    // Get user's subscriptions
    DataSnapshot userSubscriptionData = event.snapshot;
    Map subData = Map<String, int>.from(userSubscriptionData.value);
    List<String> subscriptions = subData.keys.toList();

    // Register for each subscription a listener for downs posted in that chanel
    for (String i in subscriptions) {
      dbAllSponsoredDowns.child(i).onChildAdded.listen(_onSponsoredDownAdded);
    }
  }

  _onSponsoredDownAdded(Event event) async {
    // This listener fires when we get a sponsored down
    SponsoredDown temp = await SponsoredDown.populateDown(event.snapshot);
    this.sponsoredDowns.add(temp);
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
    return Scaffold(
      appBar: this.makeAppBar(),
      bottomNavigationBar: RaisedButton(
        child: Text("Give Feedback"),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FeedbackPage(user)));
        },
      ),
      body: downs.length + sponsoredDowns.length == 0
          ? Center(
              child: new Text("You have no Downs. Add one now!",
                  style: Theme.of(context).textTheme.headline6))
          : ListView.builder(
              itemBuilder: (context, index) {
                if (index >= downs.length) {
                  return new SponsoredDownEntry(
                      this.user, sponsoredDowns[index - downs.length]);
                } else {
                  // TODO: put gesture detector here so we
                  // TODO: can detect tap and collapse all other downs
                  return new DownEntry(this.user, downs[index]);
                }
              },
              itemCount: downs.length + sponsoredDowns.length),
    );
  }
}
