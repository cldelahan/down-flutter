/*
Author: Conner Delahanty

Displays a setting page where the user can change underlying data about
themselves.

Notes:
  We presently decided to put the permission and contact reading on this page.
  We could force it on the user earlier, but that requires choosing the
  permissions. If a user doesn't give us permission, they are unlikely to
  adjust it later on, meaning they will not get access to the import-contacts
  feature.

  We can draw attention to this feature perhaps by starting pop-up, or other
  means.


*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:contacts_service/contacts_service.dart';


import 'package:down/Models/User.dart';
import 'package:down/Pages/ImportContactsPage.dart';

class SettingsPage extends StatefulWidget {
  FirebaseUser user;

  SettingsPage(this.user);

  @override
  _SettingsPageState createState() => _SettingsPageState(this.user);
}

class _SettingsPageState extends State<SettingsPage> {
  FirebaseUser user;
  DatabaseReference dbAllUsers;
  User currentUser = new User();

  _SettingsPageState(this.user);

  @override
  void initState() {
    super.initState();
    dbAllUsers =
        FirebaseDatabase.instance.reference().child("users/${this.user.uid}");
    print("Setting listener");
    dbAllUsers.onValue.listen(_getUserData);
  }

  void _getUserData(Event event) {
    print("Pre settings page");
    print("Settings page: " + event.snapshot.value.toString());
    print("SETTINGS PAGE: " + event.snapshot.key.toString());
    User temp = User.populateFromDataSnapshotAndPhone(event.snapshot, user);
    this.currentUser = temp;
    print(this.currentUser.email);

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(100.0),
              child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Column(children: <Widget>[
                    Row(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              left: 16.0, top: 16.0, right: 16.0),
                          child: Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image:
                                          this.currentUser.getImageOfUser())))),
                      //SizedBox(width: 10.0),
                      Text(
                        currentUser.profileName,
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontFamily: "Lato"),
                        textAlign: TextAlign.center,
                      )
                    ]),
                    Text(currentUser.email,
                        style: TextStyle(fontSize: 20, color: Colors.black))
                  ])),
            ),
            body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("Account Settings",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontFamily: "Lato"),
                          textAlign: TextAlign.left)),
                  SizedBox(height: 5.0),
                  settingEntry("Change Profile Name", Icons.perm_identity),
                  settingEntry("Change Password", Icons.fingerprint),
                  settingEntry("Change Image", Icons.image),
                  settingEntry("Delete Account", Icons.delete),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("Notification Settings",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontFamily: "Lato"),
                          textAlign: TextAlign.left)),
                  SizedBox(height: 5.0),
                  settingEntry("Toggle Push Notifications", Icons.toll),
                  settingEntry("Notification Options", Icons.notifications),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("More",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontFamily: "Lato"),
                          textAlign: TextAlign.left)),
                  SizedBox(height: 5.0),
                  importContactEntry(),
                  settingEntry("Tutorial", Icons.bookmark),
                  settingEntry("Privacy Policy", Icons.gavel)
                ]))));
  }

  Widget importContactEntry() {
    return GestureDetector(
        onTap: () async {
          // first need to check permission to read contacts
          /*bool readContactPermissionAlreadySet = await SimplePermissions.checkPermission(Permission.ReadContacts);
        if (!readContactPermissionAlreadySet) {
          PermissionStatus status = await SimplePermissions.requestPermission(Permission.ReadContacts);
          if (status == PermissionStatus.authorized) {
            // we are good to go
            print("We have permission");
          }
        }*/
          Iterable<Contact> contacts =
              await ContactsService.getContacts(withThumbnails: false);

          List<User> users = [];
          for (Contact i in contacts) {
            print(i.displayName);
            User temp = new User();
            temp.profileName = i.displayName;
            temp.phoneNumber = "";
            if (i.phones.length == 1) {
              temp.cleanAndAddPhoneNumber(i.phones.elementAt(0).value);
            } else {
              for (Item num in i.phones) {
                if (num.label == "mobile") {
                  temp.cleanAndAddPhoneNumber(num.value);
                }
              }
            }
            users.add(temp);
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ImportContactsPage(this.user, users)));
        },
        child: ListTile(
            leading: Icon(Icons.contacts, size: 35),
            title: Text("Import contacts")));
  }

  Widget settingEntry(String title, IconData icon) {
    return GestureDetector(
        onTap: () {
          sampleOnClick();
        },
        child: ListTile(
          leading: Icon(icon, size: 35),
          title: Text(title),
        ));
  }

  Future<dynamic> sampleOnClick() {
    SimpleDialog s = SimpleDialog(
      title: Text("Sample onClick",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      children: <Widget>[
        SimpleDialogOption(
          child: Text("Testing Setting", style: TextStyle(color: Colors.green)),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );

    return showDialog(
        context: context,
        builder: (context) {
          return s;
        });
  }
}
