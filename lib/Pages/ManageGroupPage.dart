/*
  Author: Conner Delahanty

  This page allows the user to create groups and put their friends into
  self-defined groups.
  
  Notes:

 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/User.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:down/Models/Group.dart';
import 'package:down/Widgets/ProgressWidget.dart';

class ManageGroupPage extends StatefulWidget {
  FirebaseUser user;

  ManageGroupPage(this.user);

  @override
  _ManageGroupPageState createState() => _ManageGroupPageState(this.user);
}

class _ManageGroupPageState extends State<ManageGroupPage> {
  FirebaseUser user;
  DatabaseReference dbGroups;
  DatabaseReference dbFriends;
  DatabaseReference dbAllUsers;

  final _groupKey = new GlobalKey<FormState>();

  List<User> _friends = [];

  List<User> _chosenFriends = [];

  String _groupName;

  _ManageGroupPageState(this.user);

  @override
  void initState() {
    super.initState();
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");

    dbFriends = FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/friends");

    dbGroups =
        FirebaseDatabase.instance.reference().child("users/${user.uid}/groups");

    dbFriends.onChildAdded.listen(_onFriendAdded);
  }

  _onFriendAdded(Event event) async {
    DataSnapshot friendInfo = await dbAllUsers.child(event.snapshot.key).once();
    User temp = User.populateFromDataSnapshotAndPhone(friendInfo, user);
    setState(() {
      _friends.add(temp);
    });
  }

  _createGroup() {
    // add chosenFriends to personal group
    for (User i in this._chosenFriends) {
      dbGroups.child(this._groupName).update({
        i.id: 0,
      });
    }
  }

  Widget chooseNameField() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
        child: TextFormField(
          onChanged: (value) {
            this._groupName = value;
          },
          validator: (value) {
            if (value.length == 0) {
              return "Invalid name";
            }
          },
          decoration: InputDecoration(
            hintText: "Enter Name",
          ),
        ));
  }

  Widget buildFriendList() {
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Container(
            child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: this._friends.length,
          itemBuilder: (BuildContext context, int index) {
            if (_friends[index] == null) {
              return new Container(color: Colors.transparent);
            }
            return new GestureDetector(
                onTap: () {
                  this._chosenFriends.add(_friends[index]);
                  this._friends.remove(_friends[index]);
                  setState(() {});
                },
                child: ListTile(
                    leading: new Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: this._friends[index].getImageOfUser()))),
                    title: Text(this._friends[index].profileName)));
          },
        )));
  }

  Widget createGroupButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
        child: new Material(
            color: Colors.transparent,
            child: new Center(
                child: new RaisedButton(
              child: Text("Create Group"),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                // before submitting make sure the form is valid
                if (!_groupKey.currentState.validate()) {
                  return;
                }
                // if no image was specified set their image to default
                // put photo in firebase
                // fill out their database location
                _createGroup();
                // move to the homepage
                Navigator.pop(context);
              },
            ))));
  }

  Widget buildChosenFriendsDisplay() {
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Container(
            height: 100,
            width: 1000,
            decoration: BoxDecoration(
                border: Border.symmetric(
                    vertical: BorderSide(
              width: 2.0,
              color: Colors.black,
            ))),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: this._chosenFriends.length,
                itemBuilder: (BuildContext context, int index) {
                  if (_chosenFriends[index] == null) {
                    return new Container(color: Colors.transparent);
                  }
                  return new GestureDetector(
                      onTap: () {
                        this._friends.add(_chosenFriends[index]);
                        this._chosenFriends.removeAt(index);
                        setState(() {});
                      },
                      child: new Column(children: <Widget>[
                        new Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: _chosenFriends[index]
                                        .getImageOfUser()))),
                        new Text(
                          this._chosenFriends[index].profileName,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        )
                      ]));
                })));
  }

  Widget showChosenNames() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: new SingleChildScrollView(
                child: Column(children: <Widget>[
      new Form(key: _groupKey, child: chooseNameField()),
      buildChosenFriendsDisplay(),
      buildFriendList(),
      createGroupButton(),
    ]))));
  }
}
