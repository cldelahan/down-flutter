/*
  Author: Vance Wood, Conner Delahanty

  This page allows the user to specify which friends and groups to add to
  the down.

  Notes:

 */
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/RecommendedActivity.dart';
import 'package:down/Models/Down.dart';
import 'package:down/DownCreation/CreateDownTimeScreen.dart';
import 'package:down/Models/User.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:down/Models/Group.dart';
import 'package:down/Pages/HomePage.dart';

const color1 = const Color(0xff26c586);
String value = "";

class CreateDownInviteScreen extends StatefulWidget {
  final FirebaseUser user;
  Down _builtDown;

  CreateDownInviteScreen(this.user, this._builtDown);

  @override
  _CreateDownInviteScreenState createState() =>
      _CreateDownInviteScreenState(this.user, this._builtDown);
}

class _CreateDownInviteScreenState extends State<CreateDownInviteScreen>
    with AutomaticKeepAliveClientMixin {
  FirebaseUser user;
  List<User> friends = [];
  List<Group> groups = [];
  List<String> uids;

  DatabaseReference dbAllUsers;
  DatabaseReference dbFriends;
  DatabaseReference dbGroups;
  DatabaseReference dbDowns;

  bool wantKeepAlive = false;
  Down _builtDown;

  _CreateDownInviteScreenState(this.user, this._builtDown);

  @override
  void initState() {
    super.initState();
    print("Initializeing CreateDownInviteScreen");
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");
    // pointing the reference to the user's friends and groups
    dbFriends = FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/friends");
    dbGroups =
        FirebaseDatabase.instance.reference().child("users/${user.uid}/groups");
    dbDowns =
        FirebaseDatabase.instance.reference().child("down");

    // registering listeners to populate friends / groups lists
    dbFriends.onChildAdded.listen(_onFriendAdded);
    dbGroups.onChildAdded.listen(_onGroupAdded);
  }

  _onFriendAdded(Event event) async {
    DataSnapshot friendInfo = await dbAllUsers.child(event.snapshot.key).once();
    setState(() {
      friends.add(User.populateFromDataSnapshot(friendInfo));
    });
    print("Added user");
    print(friendInfo.toString());
  }

  _onGroupAdded(Event event) async {
    Group temp = new Group(name: event.snapshot.key);
    List<String> memberIDs =
    List<String>.from(event.snapshot.value.keys.toList());
    temp.memberIDs = memberIDs;
    temp.nMembers = memberIDs.length;

    List<User> members = [];
    for (int i = 0; i < memberIDs.length; i++) {
      DataSnapshot friendInfo = await dbAllUsers.child(memberIDs[i]).once();
      members.add(User.populateFromDataSnapshot(friendInfo));
    }
    temp.members = members;

    setState(() {
      groups.add(temp);
    });
    print("Added group");
    print("Event key: " + event.snapshot.key);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: SafeArea(
          // notice, this gesture detector was homemade
          // we can change this to something more formal (shows intermedaite sliding)
          // but wanted to keep this to show some flexibility
          // TODO: change to more rigorous approach
            child: GestureDetector(
                onVerticalDragUpdate: (dragUpdateFeatures) {
                  if (dragUpdateFeatures.delta.dy < -8) {
                    // We update firebase with new downs
                    _uploadToFirebase();
                    Navigator.pushAndRemoveUntil(
                      context, MaterialPageRoute(
                        builder: (context) => HomePage(this.user)),
                          (Route<dynamic> route) => false,
                    );
                  }

                },
                child: Material(
                    child: new Column(children: <Widget>[
                      new Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
                          child: Text("Groups",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ))),
                      buildGroupList(),
                      new Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
                          child: Text("Friends",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ))),
                      buildFriendList(),
                    ])))));
  }

  void _uploadToFirebase() {
    Set<String> invitedIds = new Set<String>();
    for (int i = 0; i < this.friends.length; i++) {
      if (this.friends[i].invite) {
        invitedIds.add(this.friends[i].id);
      }
    }
    for (int i = 0; i < this.groups.length; i++) {
      if (this.groups[i].invite) {
        for (int j = 0; j < this.groups[i].memberIDs.length; j++) {
          invitedIds.add(this.groups[i].memberIDs[j]);
        }
      }
    }
    invitedIds.add(this.user.uid);


    List<String> allInvitedUids = invitedIds.toList();
    print(allInvitedUids.toString());

    var newChild = dbDowns.push();
    newChild.set({
      'creator': this.user.uid,
      'title': this._builtDown.title,
      'timeCreated': this._builtDown.timeCreated.toString(),
      'time': this._builtDown.time.toString(),
    });

    print(newChild.key);


    for (int i = 0; i < allInvitedUids.length; i++) {
      // for each user, add the downs to their page
      // newChild.key is the new down uid
      dbAllUsers.child(allInvitedUids[i]).child("downs").update({
        newChild.key: 0});
      // then, on the down page, in the invited field, add a child
      // with the key their UID, then 0 denoting not down, and
      // 1 denoting down
      if (allInvitedUids[i] == this.user.uid) {
        newChild.child("invited").child(allInvitedUids[i]).set(true);
      } else {
        newChild.child("invited").child(allInvitedUids[i]).set(false);
      }
    }
  }

Widget buildFriendList() {
  return Container(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: friends.length,
          itemBuilder: (BuildContext context, int index) {
            return new CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool newValue) {
                  setState(() {
                    friends[index].invite = newValue;
                  });
                },
                value: friends[index].invite,
                title: Text(friends[index].profileName));
          }));
}

Widget buildGroupList() {
  return Container(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: groups.length,
          itemBuilder: (BuildContext context, int index) {
            if (groups[index] == null) {
              return new Container(color: Colors.transparent);
            }
            return new CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool newValue) {
                setState(() {
                  groups[index].invite = newValue;
                });
              },
              value: groups[index].invite,
              title: Text(groups[index].name),
              subtitle: Text(groups[index].getMemberDisplay()),
            );
          }));
}

// this is creating a route between two pages
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        CreateDownTimeScreen(this.user, this._builtDown),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // a "tween" allows us to create an animation between the two pages
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      // this tween defined the movement between the two pages plus the
      // sigmoid curve effect
      var tween =
      Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}}
