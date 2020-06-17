/*
  Author: Conner Delahanty

  This page allows the user to add a friend to their list. Also, will contain
  functionality to add friends from contact book.

  Notes:

 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/User.dart';


class AddFriendPage extends StatefulWidget {
  FirebaseUser user;

  AddFriendPage(this.user);

  @override
  _AddFriendPageState createState() => _AddFriendPageState(this.user);
}

class _AddFriendPageState extends State<AddFriendPage> {
  FirebaseUser user;
  DatabaseReference dbAllUsers;
  DatabaseReference dbAllFriends;
  List<String> _friendUids = [];

  String _searchText;

  List<User> _searchedUsers = [];

  _AddFriendPageState(this.user);

  TextEditingController searchTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbAllUsers = FirebaseDatabase.instance.reference().child("users");
    dbAllFriends = FirebaseDatabase.instance
        .reference()
        .child("users/${user.uid}/friends");
    dbAllFriends.onChildAdded.listen(_onFriendAdded);
  }

  _onFriendAdded(Event event) {
    this._friendUids.add(event.snapshot.key);
  }

  _onNewSearch(String searchString) async {
    // clear all old users when new search string comes in
    this._searchedUsers.clear();

    // get entire snapshot of the database
    // TODO: This may be innefficient but is similar to Down1.0
    // What ways can we optimize this?
    DataSnapshot friendsUnderSearch =
        await dbAllUsers.orderByChild("profileName").once();
    Map entry = friendsUnderSearch.value;
    for (String i in entry.keys) {
      // if we have gotten 10 users already, then quit
      // TODO: set 10 as a global constant
      if (this._searchedUsers.length > 10) {
        break;
      }
      // check that the user is not already a friend
      if (i == this.user.uid || this._friendUids.contains(i)) {
        continue;
      } else {
        // check if a user's profile name contains our search string
        // or if a user's email contains our search string
        // TODO: presently, we only display name for privacy reasons. Should  we display email?
        if (entry[i]['profileName']
                .toLowerCase()
                .contains(searchString.toLowerCase()) ||
            entry[i]['email']
                .toLowerCase()
                .contains(searchString.toLowerCase()))
          // add into our working list of users
          this._searchedUsers.add(new User(
              profileName: entry[i]['profileName'],
              id: i,
              url: entry[i]['url']));
      }
    }
    // we delay here so if they type fast, we will not show any results until
    // they likewise pause
    //await Future.delayed(new Duration(milliseconds: 500));

    // refresh the page
    setState(() {});
  }

  _sendFriendRequest(User u) {
    dbAllUsers.child(u.id).child("requests").update({this.user.uid: 0});
    // Do we also want to make note of a user making a request on their own page?
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(children: <Widget>[
      searchBar(),
      buildFriendList(),
    ])));
  }

  Widget searchBar() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search here",
            icon: Icon(Icons.search),
          ),
          onChanged: (value) {
            this._searchText = value;
            _onNewSearch(this._searchText);
          },
        ));
  }

  Widget buildFriendList() {
    if (this._searchedUsers.length == 0) {
      return new Padding(
        padding: EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 0.0),
        child: Text("No users found"),
      );
    }
    return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
        child: Container(
            child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: this._searchedUsers.length,
          itemBuilder: (BuildContext context, int index) {
            if (_searchedUsers[index] == null) {
              return new Container(color: Colors.transparent);
            }
            print(_searchedUsers[index].url);
            return new GestureDetector(
                // TODO: Add swiping and swipe animation
                /*onHorizontalDragEnd: (DragEndDetails deets) {
              print("swiped");
            },*/
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return addFriendDialog(_searchedUsers[index]);
                      });
                },
                child: ListTile(
                    leading: new Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.cover,
                              image:
                                  this._searchedUsers[index].getImageOfUser(),
                            ))),
                    title: Text(this._searchedUsers[index].profileName)));
          },
        )));
  }

  Widget addFriendDialog(User u) {
    return SimpleDialog(
      title: Text("Add " + u.profileName + " as friend?",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      children: <Widget>[
        SimpleDialogOption(
            child: Text("Yes", style: TextStyle(color: Colors.black)),
            onPressed: () {
              _sendFriendRequest(u);
              Navigator.pop(context);
            }),
        SimpleDialogOption(
            child: Text("No", style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.pop(context);
            })
      ],
    );
  }
}
