/*
  Author: Conner Delahanty

  Creating a page to see friends, groups, and add additional friends and groups.

  Notes:
  An issue is how to specify managing friend requests versus managing groups.
  Presently there is one FAB at the bottom, but whether clicking on it brings
  to a choosing page, or there are multiple FABS, or there isn't even a FAB are
  all options.

  We can also use a separate tab controller, and depending on what page they
  are on will decide whether they can see friends or groups. That, though,
  I ran into issues implementing.

 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/User.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:down/Models/Group.dart';
import 'package:down/Pages/AddFriendPage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:down/Pages/ManageGroupPage.dart';


class FriendGroupPage extends StatefulWidget {
  FirebaseUser user;

  FriendGroupPage(this.user);

  @override
  _FriendGroupPageState createState() => _FriendGroupPageState(this.user);
}

class _FriendGroupPageState extends State<FriendGroupPage>
    with AutomaticKeepAliveClientMixin {
  FirebaseUser user;
  List<User> friends = [];
  List<Group> groups = [];
  List<User> requests = [];
  List<String> uids;
  DatabaseReference dbAllUsers;
  DatabaseReference dbFriends;
  DatabaseReference dbGroups;
  DatabaseReference dbRequests;

  bool wantKeepAlive = false;

  _FriendGroupPageState(this.user);

  @override
  void initState() {
    super.initState();
    print("Initializing state");
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");
    dbFriends = FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/friends");
    dbFriends.onChildAdded.listen(_onFriendAdded);

    print(user.uid);

    dbGroups =
        FirebaseDatabase.instance.reference().child("users/${user.uid}/groups");
    dbGroups.onChildAdded.listen(_onGroupAdded);

    dbRequests = FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/requests");
    dbRequests.onChildAdded.listen(_onRequestAdded);
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

  _onRequestAdded(Event event) async {
    String requestUID = event.snapshot.key;
    DataSnapshot requestInfo = await dbAllUsers.child(requestUID).once();
    this.requests.add(User.populateFromDataSnapshot(requestInfo));

    setState(() {});
  }

  _addFriend(User u) {
    // add other into user's account
    dbAllUsers.child(this.user.uid).child("friends").update({
      u.id: 0,
    });
    // add user into other's account
    dbAllUsers.child(u.id).child("friends").update({
      this.user.uid: 0,
    });
    // remove the request from this user
    dbRequests.child(u.id).remove();
    this.requests.remove(u);
    setState(() {});
  }

  _deleteRequest(User u) {
    dbRequests.child(u.id).remove();
    this.requests.remove(u);
    setState(() {});
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
                    buildGroupList(),
                  ],
                ),
                floatingActionButton: SpeedDial(
                    animatedIcon: AnimatedIcons.menu_close,
                    children: [
                      SpeedDialChild(
                        child: Icon(Icons.people),
                        label: "Add group",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ManageGroupPage(this.user)));
                        },
                      ),
                      SpeedDialChild(
                        child: Icon(Icons.person_add),
                        label: "Add friend",
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      AddFriendPage(this.user)));
                        },
                      )
                    ]))));
  }

  // TODO: Should we combine the requests and the friends together or separate
  Widget buildFriendList() {
    return Container(
        child: ListView.builder(
            // since we are building requests and friends
            itemCount: requests.length + friends.length,
            itemBuilder: (BuildContext context, int index) {
              if (index < requests.length) {
                // return new request entry
                return requestEntry(requests[index]);
              } else {
                // return new friend entry
                return friendEntry(friends[index - requests.length]);
              }
            }));
  }

  Widget friendEntry(User u) {
    return new ListTile(
        leading: new Container(
            width: 40.0,
            height: 40.0,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: u.url.startsWith("gs")
                        ? new FirebaseImage(u.url)
                        : new NetworkImage(u.url)))),
        title: Text(u.profileName));
  }

  Widget requestEntry(User u) {
    return new GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return addFriendDialog(u);
              });
        },
        child: ListTile(
            trailing: Icon(Icons.settings),
            leading: new Container(
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: u.url.startsWith("gs")
                            ? new FirebaseImage(u.url)
                            : new NetworkImage(u.url)))),
            title: Text(
              "New Request: " + u.profileName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            )));
  }

  Widget buildGroupList() {
    return Container(
        child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (BuildContext context, int index) {
              if (groups[index] == null) {
                return new Container(color: Colors.transparent);
              }
              return new ListTile(
                leading: new Container(
                  child: Icon(Icons.group, size: 40.0),
                ),
                title: Text(groups[index].name),
                subtitle: Text(groups[index].getMemberDisplay()),
              );
            }));
  }

  Widget addFriendDialog(User u) {
    return SimpleDialog(
      title: Text("Add " + u.profileName + " as friend?",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      children: <Widget>[
        SimpleDialogOption(
            child: Text("Yes", style: TextStyle(color: Colors.black)),
            onPressed: () {
              _addFriend(u);
              Navigator.pop(context);
            }),
        SimpleDialogOption(
            child: Text("No", style: TextStyle(color: Colors.black)),
            onPressed: () {
              _deleteRequest(u);
              Navigator.pop(context);
            })
      ],
    );
  }
}
