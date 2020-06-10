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

  TextEditingController _nameController;

  List<User> _friends = [];

  List<User> _chosenFriends = [];

  _ManageGroupPageState(this.user);

  @override
  void initState() {
    super.initState();
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");

    dbFriends = FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/friends");

    dbGroups =
        FirebaseDatabase.instance.reference().child("user/${user.uid}/groups");

    dbFriends.onChildAdded.listen(_onFriendAdded);
  }

  _onFriendAdded(Event event) async {
    DataSnapshot friendInfo = await dbAllUsers.child(event.snapshot.key).once();
    User temp = User.populateFromDataSnapshot(friendInfo);
    setState(() {
      _friends.add(temp);
    });
  }

  Widget chooseNameField() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
        child: TextFormField(
          controller: this._nameController,
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
                setState((){});
              },
                child: ListTile(
                leading: new Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: this._friends[index].url.startsWith("gs")
                                ? new FirebaseImage(this._friends[index].url)
                                : new NetworkImage(this._friends[index].url)))),
                title: Text(this._friends[index].profileName)));
          },
        )));
  }

  Widget showChosenNames() {
    return Container();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
              chooseNameField(),
      buildFriendList(),
    ])));
  }
}
