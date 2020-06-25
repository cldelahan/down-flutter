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
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/User.dart';
import '../Pages/UploadPage.dart';

// simple_permissions is giving issues
//import 'package:simple_permissions/simple_permissions.dart';
import 'package:contacts_service/contacts_service.dart';

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
  List<User> contactsToImport;
  List<bool> importContact;
  DatabaseReference dbUsers;
  DatabaseReference dbCurrentUser;

  _ImportContactsPageState(this.user, this.contactsToImport);

  @override
  void initState() {
    super.initState();
    dbUsers = FirebaseDatabase.instance.reference().child('users');
    dbCurrentUser =
        FirebaseDatabase.instance.reference().child('users/${user.uid}');
  }

  void _importContactsToFirebase() {
    /*
      Here we do a pretty complicated surgery to accomplish 3 things
      1) Create a user account for each friend added
        a) Add phone number, phone avatar, and aliases page (who calls them what)
      2) Denote that this new use account is a "phone-added" account
        a) Is it better to do this instead of adding phone avatar?
      3) Add the new user account as a friend to the original
      TODO: Should we give fake users friends? Or when they finally do create
      TODO: ... their own account, would they perfer to "start from scratch"
     */

    for (int i = 0; i < contactsToImport.length; i++) {
      if (importContact[i] == false || contactsToImport[i].phoneNumber == "") {
        continue;
      } else {
        // add to firebase
        // create a new child in user
        var newChild = dbUsers.push();
        newChild.set({
          'phone' : contactsToImport[i].phoneNumber,
          'addedByPhone' : true,
        });
        newChild.child("aliases").update(
            {user.uid : contactsToImport[i].profileName});

        // need to add them as a friend of the original user
        dbCurrentUser.child("friends").update({
          newChild.key: 0
        });

        print("New user sucessfully added at: ");
        print(newChild.key);

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
