import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Pages/UploadPage.dart';
import '../Widgets/SettingEntry.dart';

Widget settingsPage(context, User user, bool isSelf) {
  return MaterialApp(
      home: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0),
            child: Container(
                color: Theme.of(context).primaryColor,
                child: Column(children: <Widget>[
                  Row(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
                        child: Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new NetworkImage(user.url))))),
                    //SizedBox(width: 10.0),
                    Text(
                      user.profileName,
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontFamily: "Lato"),
                      textAlign: TextAlign.center,
                    )
                  ]),
                   Text(
                      user.email,
                      style: TextStyle(fontSize: 20, color: Colors.black)
                  )
                ])),
          ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Account Settings",
              style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: "Lato"),
              textAlign: TextAlign.left)),
            SizedBox(height: 5.0),
            settingEntry(context, "Change Profile Name", Icons.perm_identity),
            settingEntry(context, "Change Password", Icons.fingerprint),
            settingEntry(context, "Change Image", Icons.image),
            settingEntry(context, "Delete Account", Icons.delete),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("Notification Settings",
                    style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: "Lato"),
                    textAlign: TextAlign.left)),
            SizedBox(height: 5.0),
            settingEntry(context, "Toggle Push Notifications", Icons.toll),
            settingEntry(context, "Notification Options", Icons.notifications),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("More",
                    style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: "Lato"),
                    textAlign: TextAlign.left)),
            SizedBox(height: 5.0),
            settingEntry(context, "Tutorial", Icons.bookmark),
            settingEntry(context, "Privacy Policy", Icons.gavel)
      ]

      )

      ));
}
