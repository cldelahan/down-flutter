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
import '../Models/User.dart';
import 'package:down/Models/Status.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

  TextEditingController statusController = new TextEditingController();

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
    //this.down = Down.populateDown(event.snapshot);

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
        if (tempStatus.likerUids.contains(user.uid)) {
          tempStatus.likedByUser = true;
        }
        print(temp);
        this.statuses.add(tempStatus);
      }
    } else {
      print(event.snapshot.key);
      print("null status");
    }

    // this is likely not the best way to do this, but we
    // copy over whether a user is down so we can keep all data in
    // the down
    for (int i = 0; i < this.down.invitedUserIsDown.length; i++) {
      this.down.invitedUsers[i].isDown = this.down.invitedUserIsDown[i];
    }

    // sort people who are down
    this.down.invitedUsers.sort((User a, User b) {
      if (a.isDown && !b.isDown) {
        return -1;
      } else if (!a.isDown && b.isDown) {
        return 1;
      } else {
        return a.profileName.compareTo(b.profileName);
      }
    });

    if (!mounted) {
      return;
    }

    setState(() {});

    //TODO: best way to get user data linked with status data
  }

  Widget statusEntry(Status s) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 0.0),
        child: Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).accentColor, width: 1),
                borderRadius: BorderRadius.circular(10)),
            child: ListTile(
                leading: Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: s.poster.getImageOfUser()))),
                title: Text(s.poster.profileName,
                    style: Theme.of(context).textTheme.headline6),
                subtitle: Text(s.status,
                    style: Theme.of(context).textTheme.bodyText2),
                trailing: buildUpvoteButton(s))));
  }

  Widget buildUpvoteButton(Status s) {
    return Container(
        width: 30,
        child: Column(children: <Widget>[
          Text(s.nUpvoted.toString(),
              style: Theme.of(context).textTheme.bodyText2),
          GestureDetector(
              onTap: () async {
                //bool newLikeStatus = s.altLikeByUser();
                // add the user to the likers
                if (!s.likedByUser) {
                  await dbDown
                      .child("status/${s.poster.id}/likes")
                      .update({this.user.uid: 0});
                } else {
                  // it was false so delete
                  await dbDown
                      .child("status/${s.poster.id}/likes/${this.user.uid}")
                      .remove();
                }
                setState(() {});
              },
              child: Icon(Icons.arrow_drop_up,
                  color: s.likedByUser
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                  size: 30.0)),
        ]));
  }

  Widget addStatusField() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
        child: Form(
            key: _statusKey,
            child: TextFormField(
              controller: statusController,
              decoration: InputDecoration(
                hintText: "Add / Update status",
                suffixIcon: new GestureDetector(
                    onTap: () {
                      if (!_statusKey.currentState.validate()) {
                        print("error on validation");
                        return;
                      } else {
                        print("send a status");
                        dbDown.child("status").child(this.user.uid).update(
                            {'text': statusController.value.text.toString()});

                        // remove all likers (so people aren't liking new statuses)
                        dbDown
                            .child("status")
                            .child(this.user.uid)
                            .child("likes")
                            .remove();

                        setState(() {});

                        statusController.clear();
                      }
                    },
                    child: Icon(Icons.send)),
              ),
              /*onChanged: (value) {
                this._tempStatus = value;
              },*/
              validator: (value) {
                if (value == null || value.length == 0) {
                  return "Invalid name";
                }
              },
            )));
  }

  Widget buildFriendInviteSummaryDisplay() {
    // first we sort the users so the people who are down appear first
    // else we sort alphabetically
    this.down.invitedUsers.sort((User a, User b) {
      if (a.isDown && !b.isDown) {
        return -1;
      } else if (!a.isDown && b.isDown) {
        return 1;
      } else {
        return a.profileName.compareTo(b.profileName);
      }
    });

    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Container(
            height: 40,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: this.down.invitedUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  if (this.down.invitedUsers[index] == null) {
                    return new Container(color: Colors.transparent);
                  }
                  return new Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: new BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: this
                                  .down
                                  .invitedUsers[index]
                                  .getImageOfUser(),
                              fit: BoxFit.cover,
                              colorFilter: this.down.invitedUsers[index].isDown
                                  ? null
                                  : new ColorFilter.mode(
                                      Colors.black.withOpacity(0.5),
                                      BlendMode.dstATop))));
                })));
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
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
                child: SingleChildScrollView(
                    child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            border: Border.all(
                                color: Theme.of(context).accentColor, width: 1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                title: Text(this.down.creator.profileName,
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                subtitle: InkWell(
                                    onTap: () async {
                                      if (down.address == null ||
                                          down.address == "") {
                                        return;
                                      }
                                      String query =
                                          Uri.encodeComponent(down.address);
                                      String googleUrl =
                                          "https://www.google.com/maps/search/?api=1&query=$query";
                                      await launch(googleUrl);
                                    },
                                    child: Text(this.down.title,
                                        style: new TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: Theme.of(context)
                                                .textTheme
                                                .headline4
                                                .fontSize))),
                                trailing: new Stack(children: <Widget>[
                                  new Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: new BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: this
                                                  .down
                                                  .creator
                                                  .getImageOfUser()))),
                                  new Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: new Container(
                                          padding: EdgeInsets.all(1),
                                          decoration: new BoxDecoration(
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          constraints: new BoxConstraints(
                                              minWidth: 12, minHeight: 12),
                                          child: new Text(
                                              this.down.nInvited.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1)))
                                ]),
                              ),
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: Text(down.getCleanTime(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6))),
                              buildFriendInviteSummaryDisplay(),
                              buildStatusDisplay(),
                              addStatusField(),
                            ]))))));
  }
}
