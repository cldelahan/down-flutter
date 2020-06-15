/*
  Author: Conner Delahanty

  This code creates a specific DownEntry to display.

  Notes:
  There are three options to deal with modifying down entries:
  1) We can read all locally. Then have them change the local copy and do
    periodic updates
  2) We can read from DB every time. On changing down status, write to
    Firebase and the setState(), refreshing the page
      (This is what we do for users etc. However, would require either Firebase
       code duplication in this file or copying widget creation from this page
       to another)
  3) We can do a hybrid. We read a down locally, populate the DownEntry using
    that down. Then when we change that down, change the local version and then
    update the Firebase version. This may suffer from synchronous issues,
    (if internet goes out etc), but saves from constant reloading.


    This strategy currently uses strategy 3. On the down entry page, when we
    only have one down to load, we then reload using specific down data.
    There might be the case if they denote becoming down, then quickly
    tap into the entry, they catch it at a weird time.

    Is there a way to smooth this? Temporarily use the local version
    and then refresh from database later? Is this necessary / is strategy 3
    our best?
    
    UPDATE:
    While the above are valid perspectives, DownEntry code has been copied into
    FeedPage.dart to save code reuse and firebase implementation.

    File has been marked obsolete.
    
    UPDATE:
    Calling the setState() function in FeedPage will regenerate the entire 
    state (and load in new downs). As such, we will keep DownEntry.dart


 */

import 'package:flutter/material.dart';
import '../Models/Down.dart';
import '../Pages/DownEntryDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_database/firebase_database.dart';

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

  _DownEntryState(this.user, this.down);

  DatabaseReference dbAllDowns;

  @override
  void initState() {
    dbAllDowns = FirebaseDatabase.instance.reference().child("down");
  }

  @override
  Widget build(BuildContext context) {
    return handmadeBuild(down, context);
    //return cardBuild(down, context);
  }

  Widget cardBuild(Down down, BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
        child: Card(
            color: down.isDown ? Theme.of(context).primaryColor : Colors.white,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              ListTile(
                leading: Container(
                    width: 40.0,
                    height: 20.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: this.down.creator.url.startsWith("gs")
                                ? new FirebaseImage(this.down.creator.url)
                                : new NetworkImage(this.down.creator.url)))),
                title: Text(this.down.title),
                subtitle: Text(this.down.getCleanTime().toString() +
                    '\n' +
                    this.down.nDown.toString() +
                    " down\t" +
                    this.down.nInvited.toString() +
                    " invited"),
              ),
              ButtonBar(children: <Widget>[
                FlatButton(
                    child: const Text("Add to Calendar"),
                    onPressed: () {
                      print("You pressed ATC");
                    }),
                FlatButton(
                    child: const Text("Ignore"),
                    onPressed: () {
                      print("You pressed Ig");
                    })
              ])
            ])));
  }

  Widget handmadeBuild(Down down, BuildContext context) {
    print("Down toString(): " + this.down.toString());
    return Padding(
      padding: const EdgeInsets.only(right: 5, top: 15, left: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return new DownEntryDetails(this.user, down);
              },
              fullscreenDialog: true,
            ),
          );
        },
        onDoubleTap: () {
          dbAllDowns.child(down.id).child("invited").update({
            user.uid : !down.isDown
          });
          setState(() {
            down.isDown = !down.isDown;
          });
        },
        child: Container(
          color: down.isDown ? Theme.of(context).primaryColor : Colors.white,
          child: Column(children: <Widget>[
            Text(down.title,
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            Row(children: <Widget>[
              Text(down.getCleanTime(),
                  style: TextStyle(fontSize: 25, color: Colors.grey)),
              Flexible(fit: FlexFit.tight, child: SizedBox()),
              Text(down.nInvited.toString() + " invited",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.grey,
                  ))
            ]),
            Row(children: <Widget>[
              Text(down.creator.profileName,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  )),
              Flexible(fit: FlexFit.tight, child: SizedBox()),
              Text(
                  DateTime.now()
                          .difference(down.timeCreated)
                          .inHours
                          .toString() +
                      "h ago",
                  style: TextStyle(fontSize: 10.0, color: Colors.grey)),
              Flexible(fit: FlexFit.tight, child: SizedBox()),
              Text("+" + down.nDown.toString(),
                  style: TextStyle(fontSize: 10.0, color: Colors.black))
            ])
          ]),
        ),
      ),
    );
  }
}
