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
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/User.dart';
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

  _DownEntryState(this.user, this.down);

  DatabaseReference dbAllDowns;
  DatabaseReference dbAllUsers;

  bool wantKeepAlive = false;


  @override
  void initState() {
    dbAllDowns = FirebaseDatabase.instance.reference().child("down");
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");
  }

    @override
    Widget build(BuildContext context) {
      return modernBuild(context);
    }

    void _changeDownStatus() {
      dbAllDowns.child(down.id).child("invited").update(
          {user.uid: !down.isDown});
      setState(() {
        down.isDown = !down.isDown;
      });
    }


    void _navigateToDownDetails() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return DownEntryDetails(this.user, down);
          },
          fullscreenDialog: true,
        ),
      );
    }

    Widget modernBuild(context) {
      return Padding(
          padding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 0.0),
          child: GestureDetector(
              onTap: _navigateToDownDetails,
              onDoubleTap: _changeDownStatus,
              child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  decoration: BoxDecoration(
                      color: down.isDown
                          ? Theme
                          .of(context)
                          .primaryColor
                          .withOpacity(
                          down.time.isBefore(DateTime.now()) ? 0.25 : 1)
                          : Theme
                          .of(context)
                          .backgroundColor,
                      border: Border.all(
                          color: Theme
                              .of(context)
                              .accentColor, width: 1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(this.down.creator.profileName,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyText1),
                          subtitle: Text(this.down.title,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline4),
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
                                      color: Theme
                                          .of(context)
                                          .backgroundColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: new BoxConstraints(
                                        minWidth: 12, minHeight: 12),
                                    child: new Text(
                                        this.down.nInvited.toString(),
                                        style: Theme
                                            .of(context)
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
                                    Theme
                                        .of(context)
                                        .textTheme
                                        .headline6)))
                      ]))));
    }
  }