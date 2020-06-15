import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/User.dart';
import '../Pages/UploadPage.dart';

class SettingsPage extends StatefulWidget {
  FirebaseUser user;

  SettingsPage(this.user);

  @override
  _SettingsPageState createState() => _SettingsPageState(this.user);
}

class _SettingsPageState extends State<SettingsPage> {
  FirebaseUser user;
  DatabaseReference dbAllUsers;
  User currentUser;

  _SettingsPageState(this.user) {
    print("PRINTING USER: " + this.user.uid);
  }

  @override
  void initState() {
    super.initState();
    dbAllUsers =
        FirebaseDatabase.instance.reference().child("users/${this.user.uid}");

    dbAllUsers.onValue.listen(_getUserData);
  }

  void _getUserData(Event event) {
    print("Pre settings page");
    print("Settings page: " + event.snapshot.value.toString());
    print("SETTINGS PAGE: " + event.snapshot.key.toString());
    User temp = User.populateFromDataSnapshot(event.snapshot);
    this.currentUser = temp;
    print(this.currentUser.email);

    setState(() {});
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
                                  image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image:
                                          this.currentUser.url.startsWith("gs")
                                              ? new FirebaseImage(
                                                  this.currentUser.url)
                                              : new NetworkImage(
                                                  this.currentUser.url))))),
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
            body: Column(
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
                  settingEntry("Tutorial", Icons.bookmark),
                  settingEntry("Privacy Policy", Icons.gavel)
                ])));
  }

  Widget settingEntry(String title, IconData icon) {
    SimpleDialog s = SimpleDialog(
      title: Text(title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      children: <Widget>[
        SimpleDialogOption(
          child: Text("Testing Setting", style: TextStyle(color: Colors.green)),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );

    return GestureDetector(
        onTap: () {
          return showDialog(
              context: context,
              builder: (context) {
                return s;
              });
        },
        child: ListTile(
          leading: Icon(icon, size: 35),
          title: Text(title),
        ));
  }
}
