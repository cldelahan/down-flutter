/*
Author: Conner Delahanty

Displays all loaded contacts and allows a user to choose which to import into
Down.

Notes:
  The contacts are loaded when clicked on in the settings page, and the 
  array is sent to this device.
  TODO: is loading the contacts on this page more cost effective?


*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:down/Models/User.dart';

// simple_permissions is giving issues
//import 'package:simple_permissions/simple_permissions.dart';

class ImportContactsPage extends StatefulWidget {
  final FirebaseUser user;
  List<User> contactsToImport;

  ImportContactsPage(this.user, this.contactsToImport);

  @override
  _ImportContactsPageState createState() =>
      _ImportContactsPageState(this.user, this.contactsToImport);
}

class _ImportContactsPageState extends State<ImportContactsPage> {
  FirebaseUser user;
  List<User> contactsToImport = [];
  List<bool> importContact = [];
  Map allUserMap;

  DatabaseReference dbUsers;
  DatabaseReference dbCurrentUser;

  _ImportContactsPageState(this.user, this.contactsToImport) {
    for (User i in contactsToImport) {
      importContact.add(false);
    }
  }

  @override
  void initState() {
    super.initState();
    dbUsers = FirebaseDatabase.instance.reference().child('users');
    dbCurrentUser =
        FirebaseDatabase.instance.reference().child('users/${user.uid}');

    // To check if the added contact already exists, we read in the entire
    // user page. This is extremely inefficient and horrible.
    dbUsers.onValue.listen(_getAllUsers);
  }

  void _getAllUsers(Event event) {
    // storing all users for our horrible search below
    DataSnapshot userDS = event.snapshot;
    allUserMap = userDS.value;
  }

  void _importContactsToFirebase() async {
    /*
      Here we do a pretty complicated surgery to accomplish 3 things
      1) Create a user account for each friend added
        a) Add phone number, phone avatar, and aliases page (who calls them what)
      2) Denote that this new use account is a "phone-added" account
        a) Is it better to do this instead of adding phone avatar?
      3) Add the new user account as a friend to the original
     */

    for (int i = 0; i < contactsToImport.length; i++) {
      if (importContact[i] == false || contactsToImport[i].phoneNumber == "") {
        continue;
      } else {
        String uid =
            _findIfAddedAccountExistsWithPhone(contactsToImport[i].phoneNumber);
        /*
          Three cases:
          1) Null, meaning no account and create a new one
          2) Is a UID, meaning on UID add our new alias and change nothing else
          3) Is a UID, but the user has an actual Down account, and thus should
            be added
            TODO: We should make sure the user knows a friend request was sent
            TODO: ... (so they don't just see no change).
         */
        if (uid == null) {
          // Case 1
          print("Case 1");
          var newChild = dbUsers.push();
          newChild.set({
            'phone': contactsToImport[i].phoneNumber,
            'addedByPhone': true,
          });
          newChild
              .child("aliases")
              .update({user.uid: contactsToImport[i].profileName});
          // need to add them as a friend of the original user
          dbCurrentUser.child("friends").update({newChild.key: 0});
          print("New user sucessfully added at: ");
          print(newChild.key);
        } else {
          print(uid);
          // If the user already has an account (this could be shortened by
          // ... noting if uid starts with '-' it is a result of .push()
          if (allUserMap[uid]["addedByPhone"] != null &&
              allUserMap[uid]["addedByPhone"] == true) {
            // Case 2
            print("Case 2");
            dbUsers
                .child(uid)
                .child("aliases")
                .update({this.user.uid: contactsToImport[i].profileName});
            dbCurrentUser.child("friends").update({uid: 0});
          } else {
            print("Case 3");
            // Case 3, send friend request
            // (unless they are already friends)
            if (allUserMap[this.user.uid]['friends'] != null &&
                allUserMap[this.user.uid]['friends'][uid] != null) {
              // they are already friends
              print("Case 3 - already friends. No change.");
            } else {
              print("Case 3 - sending request to new friends");
              dbUsers.child(uid).child("requests").update({this.user.uid: 0});
            }
          }
        }
      }
    }
  }

  Widget buildDisplayList() {
    return Expanded(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: this.contactsToImport.length,
            itemBuilder: (BuildContext context, int index) {
              return new CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool newValue) {
                  setState(() {
                    this.importContact[index] = newValue;
                  });
                },
                value: this.importContact[index],
                title: Text(this.contactsToImport[index].profileName),
                subtitle: Text(this.contactsToImport[index].phoneNumber),
              );
            }));
  }

  Widget displayTitle() {
    return new Center(
        child: new Text("Import Contacts",
            style: new TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w300,
                fontFamily: "Lato",
                fontSize: 40.0)));
  }

  Widget selectAllOrClear() {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new RaisedButton(
              child: Text("Select All"),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                for (int i = 0; i < this.contactsToImport.length; i++) {
                  this.importContact[i] = true;
                }
                setState(() {});
              }),
          new SizedBox(width: 40.0),
          new RaisedButton(
              child: Text("Clear All"),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                for (int i = 0; i < this.contactsToImport.length; i++) {
                  this.importContact[i] = false;
                }
                setState(() {});
              })
        ]);
  }

  Widget importBottomButton() {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new RaisedButton(
              child: Text("Submit"),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                _importContactsToFirebase();
                Navigator.pop(context);
                // make the call to firebase to store all friends
              }),
        ]);
  }

  String _findIfAddedAccountExistsWithPhone(String pn) {
    /*
      Purpose: If another user has added this person by phone,
      we only want one copy of that user (with another 
      alias added).
      Returns UID of user, and null if no user exists.
      
      This function is presently terribly inefficient.
      I cannot figure out how to constant-time query
      Firebase RealTimeDatabase. So we are linearly searching the
      entire database.

      TODO: We could slightly optimize this by noting all uids added
      TODO: ... by .push() start with '-'
      TODO: Make this less horrible
     */
    List<String> allUserUIDs = List<String>.from(allUserMap.keys);
    for (String uid in allUserUIDs) {
      // If this is the correct user
      if (allUserMap[uid]["phone"] == pn) {
        // If this user was added by phone, we return UID so we don't create
        // ... duplicates.
        return uid;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext build) {
    return new Material(
        child: new Padding(
            padding: EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 0.0),
            child: new Column(children: <Widget>[
              displayTitle(),
              selectAllOrClear(),
              buildDisplayList(),
              importBottomButton()
            ])));
  }
}
