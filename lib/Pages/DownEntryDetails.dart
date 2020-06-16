/*
  Author: Conner Delahanty

  Display down entry details, statuses, and who is coming / more information
  about the down.

  Notes:
    6/12/20:

    Statuses pose an interesting issue. Keeping the status widget in this file,
    if we upvote a status, we have to reload the page to show it. However, this
    results in having all the statuses magically vanish and then come back again.

    We can also not clear out the status array between updates. However, the
    status array will get really large and show different statuses.

    Finally, we can search through the status array and update, but this still
    would require reloading the page.

    Solution: A new file called StatusEntry was created in widgets (stateful).
    We can run this status's "setState((){});" function, which will refresh the
    status, but leave the rest of the page untouched.
    (Problem: we have to pass down and entry data to the status entry page)

    TODO: Will there be miscommunication issues between StatusEntry and
    TODO: DownEntryDetails? Only time will tell!

 */

import 'package:flutter/material.dart';
import '../Models/Down.dart';
import '../Widgets/HeaderWidget.dart';
import '../Models/User.dart';
import 'package:down/Models/Status.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_image/firebase_image.dart';

class DownEntryDetails extends StatefulWidget {
  Down down;
  FirebaseUser user;

  DownEntryDetails(this.user, this.down);

  @override
  _DownEntryDetailsState createState() =>
      _DownEntryDetailsState(this.user, this.down);
}

class _DownEntryDetailsState extends State<DownEntryDetails>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  FirebaseUser user;
  Down down;
  DatabaseReference dbDown;
  DatabaseReference dbAllUsers;
  List<Status> statuses = [];
  final Map<String, User> uidToUser = {};

  final _statusKey = new GlobalKey<FormState>();

  String _tempStatus;

  bool wantKeepAlive = false;

  _DownEntryDetailsState(this.user, this.down);

  @override
  initState() {
    super.initState();
    dbDown = FirebaseDatabase.instance.reference().child("down").child(down.id);
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");

    // we will register a listener for dbDown to get this down.
    // this is a little silly because we already know the down exists.
    // The advantages of "rereading" the down at this point are that we don't
    // have to load all the statuses, likes, pictures, etc. on the feed page
    // (feed page should be high-performing and often has many downs)

    dbDown.onValue.listen(_readDownInfo);
  }

  void _readDownInfo(Event event) async {
    // we want to read the down information (reread to update from firebase)
    // and then add statuses. We will store the statuses here locally instead
    // of in the down (TODO: Is this best?)
    print(event.snapshot.value);
    print(event.snapshot.key);

    print("repopulating the down");

    // TODO: Decide if it is worth repopulating the down
    this.down = Down.populateDown(event.snapshot);

    this.down.isDown = event.snapshot.value["invited"][user.uid];

    // we will also populate the down's invited users function
    List<User> invitedUsers = [];
    User temp;
    for (String userId in this.down.invitedIDs) {
      print("userID: " + userId);
      DataSnapshot tempDS = await dbAllUsers.child(userId).once();
      temp = User.populateFromDataSnapshot(tempDS, this.user);
      print(temp);
      invitedUsers.add(temp);
      // allows for rapid conversion between uid and User class
      uidToUser[userId] = temp;
    }
    this.down.setInvitedUsers(invitedUsers);

    this.statuses.clear();
    Status tempStatus = new Status();
    if (event.snapshot.value["status"] != null) {
      Map statusData = event.snapshot.value["status"];
      // iterate through number of statuses
      for (String statusCreator in statusData.keys) {
        User poster = this.uidToUser[statusCreator];
        tempStatus.poster = poster;
        tempStatus.status = statusData[statusCreator]["text"];
        tempStatus.countLikers(statusData[statusCreator]["likes"]);
        print(temp);
        this.statuses.add(tempStatus);
      }
    } else {
      print(event.snapshot.key);
      print("null status");
    }

    if (!mounted) {
      return;
    }

    setState(() {});

    //TODO: best way to get user data linked with status data
  }

  Widget statusEntry(Status s) {
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
                      image: s.poster.getImageOfUser())),
              SizedBox(width: 10.0),
              Text(s.poster.profileName,
                  style: TextStyle(
                      fontSize: 20, color: Colors.black, fontFamily: "Lato")),
            ]),
            Row(children: <Widget>[
              SizedBox(
                height: 50.0,
                width: 20.0,
              ),
              Flexible(
                  child: Text(s.status,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontFamily: "Lato")))
            ]),
            Row(children: <Widget>[
              Flexible(fit: FlexFit.tight, child: SizedBox()),
              Text(s.nUpvoted.toString(),
                  style: TextStyle(
                      fontSize: 20, color: Colors.black, fontFamily: "Lato")),
              Container(
                // TODO: There is a weird bug where it takes two taps to unlike
                /*
                  Why?: Likely because the SetState() function runs faster than
                  we update the database, so while we refresh the local version,
                  we replace it with a out-of-date later version.
                 */
                child: GestureDetector(
                    onTap: () async {
                      s.likedByUser = !s.likedByUser;
                      // add the user to the likers
                      if (s.likedByUser == true) {
                        await dbDown
                            .child("status/${s.poster.id}/likes")
                            .update({this.user.uid: 0});
                      } else {
                        // it was false so delete
                        await dbDown
                            .child(
                                "status/${s.poster.id}/likes/${this.user.uid}")
                            .remove();
                      }
                      setState(() {});
                    },
                    child: Icon(Icons.arrow_drop_up,
                        color: s.likedByUser
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                        size: 30.0)),
                alignment: Alignment.bottomRight,
              )
            ])
          ]),
        ));
  }

  Widget addStatusField() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
        child: Form(
            key: _statusKey,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: "Add / Update status",
                suffixIcon: new GestureDetector(
                    onTap: () {
                      if (!_statusKey.currentState.validate()) {
                        print("error on validation");
                        return;
                      } else {
                        print("send a status");
                        dbDown
                            .child("status")
                            .child(this.user.uid)
                            .update({'text': this._tempStatus});

                        // remove all likers (so people aren't liking new statuses)
                        dbDown
                            .child("status")
                            .child(this.user.uid)
                            .child("likes")
                            .remove();

                        setState(() {});
                      }
                    },
                    child: Icon(Icons.send)),
              ),
              onChanged: (value) {
                this._tempStatus = value;
              },
              validator: (value) {
                if (value == null || value.length == 0) {
                  return "Invalid name";
                }
              },
            )));
  }

  Widget buildFriendInviteSummaryDisplay() {
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Container(
            height: 150,
            width: 1000,
            decoration: BoxDecoration(
                border: Border.symmetric(
                    vertical: BorderSide(
              width: 2.0,
              color: Colors.black,
            ))),
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: this.down.invitedUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  if (this.down.invitedUsers[index] == null) {
                    return new Container(color: Colors.transparent);
                  }

                  print(this.down.invitedUserIsDown);
                  return new Container(
                      color: this.down.invitedUserIsDown[index]
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      child: ListTile(
                          leading: new Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image:  this
                                              .down
                                              .invitedUsers[index]
                                              .getImageOfUser())),
                          title:
                              Text(this.down.invitedUsers[index].profileName)));
                  /*
                  return new Container(
                      width: 70.0,
                      child: new Column(children: <Widget>[
                        new Container(
                          width: 50,
                          height: 50,
                          decoration: new BoxDecoration(
                            image: DecorationImage(
                                this
                                .down
                                .invitedUsers[index]
                                .url
                                .startsWith("gs")
                                ? new FirebaseImage(
                                this.down.invitedUsers[index].url)
                                : new NetworkImage(
                                this.down.invitedUsers[index].url))),
                          ),
                        new Text(
                          this.down.invitedUsers[index].profileName,
                          softWrap: true,
                        )
                      ]));*/
                })));
  }

  Widget buildDownHeading() {
    return Container(
      // color: down.isDown ? Theme.of(context).primaryColor : Colors.white,
      color: Colors.white,
      child: Column(children: <Widget>[
        Text(down.title,
            style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 5.0),
        Row(children: <Widget>[
          (down.address != null)
              ? Text(down.address,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ))
              : Container(),
        ]),
        SizedBox(height: 5.0),
        Row(children: <Widget>[
          Text(down.getCleanTime(),
              style: TextStyle(fontSize: 20, color: Colors.black)),
        ]),
        SizedBox(height: 30.0),
        // spacing between time and Down / Havent Seen / Invited
        Text(down.getGoingSummary()),
      ]),
    );
  }

  Widget buildStatusDisplay() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return statusEntry(this.statuses[index]);
        },
        itemCount: this.statuses.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = header(context,
        user: this.user, isAppTitle: true, disappearedBackButton: false);
    return Scaffold(
        appBar: appBar,
        body: Padding(
            padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
            child: SingleChildScrollView(
                child: Container(
                    /*color: down.isDown
                        ? Theme.of(context).primaryColor
                        : Colors.white,*/
                    color: Colors.white,
                    child: Column(children: <Widget>[
                      buildDownHeading(),
                      buildFriendInviteSummaryDisplay(),
                      buildStatusDisplay(),
                      addStatusField(),
                    ])))));
  }
}
