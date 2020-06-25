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
  FirebaseUser user;
  Down down;

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

  TextEditingController statusController = new TextEditingController();
  final _statusKey = new GlobalKey<FormState>();
  bool wantKeepAlive = false;

  _DownEntryDetailsState(this.user, this.down);

  @override
  initState() {
    super.initState();
    dbDown = FirebaseDatabase.instance.reference().child("down").child(down.id);
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");

    /*
      Previously - we would re-populate this down on this screen. Now we have
      already loaded the down.
      Don't know whether is best to register listeners (status-change,
      # downs-change) on the down object or here or Feed page yet.
     */
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
                trailing: Container(
                    width: 30,
                    child: Column(children: <Widget>[
                      Text(s.getNumberOfLikes().toString(),
                          style: Theme.of(context).textTheme.bodyText2),
                      GestureDetector(
                          onTap: () async {
                            //bool newLikeStatus = s.altLikeByUser();
                            // add the user to the likers
                            if (!s.isLikedByUser(this.user.uid)) {
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
                              color: s.isLikedByUser(this.user.uid)
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                              size: 30.0)),
                    ])))));
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
    // TODO: find best way to sort
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Container(
            height: 40,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: this.down.invitedUserIDs.length,
                itemBuilder: (BuildContext context, int index) {
                  if (this.down.invitedUserIDs[index] == null) {
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
                                  .getUserObject(index)
                                  .getImageOfUser(),
                              fit: BoxFit.cover,
                              colorFilter: this.down.invitedUserIsDown[index]
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
          return statusEntry(this.down.statusesMap.values.elementAt(index));
        },
        itemCount: this.down.statusesMap.length,
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6))),
                              buildFriendInviteSummaryDisplay(),
                              buildStatusDisplay(),
                              addStatusField(),
                            ]))))));
  }
}
