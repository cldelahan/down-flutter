/*
  Author: Conner Delahanty

  Creating a page to see friends, groups, and add additional friends and groups.

  Notes:

 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/User.dart';
import 'package:firebase_image/firebase_image.dart';

class FriendGroupPage extends StatefulWidget {
  FirebaseUser user;

  FriendGroupPage(this.user);

  @override
  _FriendGroupPageState createState() => _FriendGroupPageState(this.user);
}

class _FriendGroupPageState extends State<FriendGroupPage> with AutomaticKeepAliveClientMixin{
  FirebaseUser user;
  List<User> friends = [];
  List<String> uids;
  DatabaseReference dbAllUsers;
  DatabaseReference dbFriends;

  bool wantKeepAlive = true;

  _FriendGroupPageState(this.user);

  @override
  void initState() {
    super.initState();
    print("Initializing state");
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");
    dbFriends = FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/friends");
    dbFriends.onChildAdded.listen(_onUserAdded);
  }

  _onUserAdded(Event event) async {
    DataSnapshot friendInfo = await dbAllUsers.child(event.snapshot.key).once();
    setState(() {
      friends.add(User.populateFromDataSnapshot(friendInfo));
    });
    print("Added user");
    print(friendInfo.toString());
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).primaryColor,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              bottom: TabBar(
                tabs: [
                  Tab(text: "Friends"),
                  Tab(text: "Groups"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                buildFriendList(),
                Icon(Icons.directions_transit),
              ],
            ),
            floatingActionButton: new FloatingActionButton(
                onPressed: () {
                  print("FAB Pressed");
                },
                child: Icon(Icons.add),
                backgroundColor: Theme.of(context).primaryColor),
          ),
        ));
  }

  Widget buildFriendList() {
    return Container(
        child: ListView.builder(
      itemCount: friends.length,
      itemBuilder: (BuildContext context, int index) {
        if (friends[index] == null) {
          return new Container(color: Colors.transparent);
        }
        print(friends[index].url);
        return new ListTile(
            leading: new Container(
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image:
                            friends[index].url.startsWith("gs")
                                ? new FirebaseImage(friends[index].url)
                                : new NetworkImage(friends[index].url)))),
            title: Text(friends[index].profileName));
      },
    ));
  }
}
