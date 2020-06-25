/*
  Author: Conner Delahanty

  This code creates an expandable down entry - an entry that when tapped
  expands and shows more information about the down. This code is closely
  related to the DownEntry.dart code.

  Notes:
  All values about the down are loaded when the app loads (in the Feed Page).
  This page registers a listener so if any component of the down changes
  it can rebuild.

 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:down/Models/Down.dart';
import 'package:down/Models/User.dart';
import 'package:down/Models/Status.dart';

class DownEntry extends StatefulWidget {
  Down down;
  FirebaseUser user;

  DownEntry(this.user, this.down);

  @override
  _DownEntryState createState() => _DownEntryState(this.user, this.down);
}

class _DownEntryState extends State<DownEntry> {
  Down down;
  FirebaseUser user;
  bool isDetailed = false;

  DatabaseReference dbDown;
  final Map<String, User> uidToUser = {};

  final _statusKey = new GlobalKey<FormState>();

  String _tempStatus;

  bool wantKeepAlive = false;

  TextEditingController statusController = new TextEditingController();

  _DownEntryState(this.user, this.down);

  @override
  void initState() {
    dbDown = FirebaseDatabase.instance.reference().child("down").child(down.id);
    dbDown.onChildChanged.listen(_downDataChanged);
  }

  void _downDataChanged(Event event) async {
    print("refreshing the down");
    await this.down.setAttribute(event.snapshot.key, event.snapshot.value);
    setState(() {});
  }

  void _changeDownStatus() {
    dbDown.child("invited").update({user.uid: !down.isUserDown(this.user.uid)});
    // We don't change the local copy, but instead let the database make that change
    // If the lag is annoying, we can also change the local copy here, and have it
    // be redundantly re-udpated. It would look smoother.
  }

  void _deleteDown() {
    this.down.safeDelete();
    super.setState((){});
  }

  void _navigateToDownDetails() {
    isDetailed = !isDetailed;
    setState(() {});
  }

  void _offerDeletion() {
    if (this.down.creatorID == user.uid &&
        this.down.time.isAfter(DateTime.now())) {
      SimpleDialog s = SimpleDialog(
        title: Text("Delete down?",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        children: <Widget>[
          SimpleDialogOption(
              child: Text("Yes", style: TextStyle(color: Colors.black)),
              onPressed: () {
                _deleteDown();
                Navigator.pop(context);
              }),
          SimpleDialogOption(
              child: Text("No", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      );
      showDialog(
          context: context,
          builder: (context) {
            return s;
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
        duration: Duration(seconds: 1),
        child: !isDetailed ? smallEntry(context) : buildDownEntryDetails());
  }

  Widget smallEntry(context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 0.0),
        child: GestureDetector(
            onTap: _navigateToDownDetails,
            onDoubleTap: _changeDownStatus,
            onLongPress: _offerDeletion,
            child: Container(
                decoration: BoxDecoration(
                    color: down.isUserDown(user.uid)
                        ? Theme.of(context).primaryColor.withOpacity(
                            down.time.isBefore(DateTime.now()) ? 0.25 : 1)
                        : Theme.of(context).backgroundColor,
                    border: Border.all(
                        color: Theme.of(context).accentColor, width: 1),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        title: Text(this.down.creator.profileName,
                            style: Theme.of(context).textTheme.bodyText1),
                        subtitle: Text(this.down.title,
                            style: Theme.of(context).textTheme.headline4),
                        trailing: new Stack(children: <Widget>[
                          new Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          this.down.creator.getImageOfUser()))),
                          new Positioned(
                              right: 0,
                              bottom: 0,
                              child: new Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).backgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: new BoxConstraints(
                                      minWidth: 12, minHeight: 12),
                                  child: new Text(
                                      this.down.getNumberInvited().toString(),
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
                                  style:
                                      Theme.of(context).textTheme.headline6)))
                    ]))));
  }

  Widget buildDownEntryDetails() {
    return GestureDetector(
        onTap: _navigateToDownDetails,
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
                                style: Theme.of(context).textTheme.bodyText1),
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
                                        color: Theme.of(context).primaryColor,
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
                                        color:
                                            Theme.of(context).backgroundColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      constraints: new BoxConstraints(
                                          minWidth: 12, minHeight: 12),
                                      child: new Text(
                                          this
                                              .down
                                              .getNumberInvited()
                                              .toString(),
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
                        ])))));
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
        child: GestureDetector(
            onTap: () async {
              //bool newLikeStatus = s.altLikeByUser();
              // add the user to the likers
              if (!s.isLikedByUser(user.uid)) {
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
            child: Column(children: <Widget>[
              Text(s.getNumberOfLikes().toString(),
                  style: Theme.of(context).textTheme.bodyText2),
              Icon(Icons.arrow_drop_up,
                  color: s.isLikedByUser(user.uid)
                      ? Theme.of(context).primaryColor
                      : Colors.black,
                  size: 30.0),
            ])));
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
    /*this.down.invitedUsers.sort((User a, User b) {
      if (a.isDown && !b.isDown) {
        return -1;
      } else if (!a.isDown && b.isDown) {
        return 1;
      } else {
        return a.profileName.compareTo(b.profileName);
      }
    });*/

    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Container(
            height: 40,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: this.down.getNumberInvited(),
                itemBuilder: (BuildContext context, int index) {
                  if (this.down.invitedUserIDs[index] == null) {
                    return new Container(color: Colors.transparent);
                  }
                  print(index);
                  print(down.getUserObject(index).id);
                  if (down.getUserObject(index).addedByPhone) {
                    return new Container(
                        width: 40.0,
                        height: 40.0,
                        child: Center(child: Text(down.getUserObject(index).getInitials(),
                            style: Theme.of(context).textTheme.bodyText2)),
                        decoration: new BoxDecoration(
                          border: Border.all(
                              width: 2.0,
                              color: this.down.isUserDown(
                                        this.down.getUserObject(index).id)
                                  ? Theme.of(context).primaryColor
                                  : Colors.black),
                          shape: BoxShape.circle,
                        ));
                  } else {
                    return new Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: new BoxDecoration(
                          border: Border.all(
                            width: 2.0,
                            color: this.down.isUserDown(
                                    this.down.getUserObject(index).id)
                                ? Theme.of(context).primaryColor
                                : Colors.black,
                          ),
                          image: DecorationImage(
                              image: this
                                  .down
                                  .getUserObject(index)
                                  .getImageOfUser(),
                              fit: BoxFit.cover),
                          shape: BoxShape.circle,
                        ));
                  }
                })));
  }

  Widget buildStatusDisplay() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return statusEntry(this.down.statusesMap.values.elementAt(index));
        },
        itemCount: this.down.statusesMap.values.length,
      ),
    );
  }
}
