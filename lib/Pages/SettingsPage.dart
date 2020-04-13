import 'package:flutter/material.dart';
import '../Models/User.dart';
import '../Pages/UploadPage.dart';

Widget settingsPage (context, User userInfo, bool isSelf) {
  return MaterialApp(
      home: Scaffold(

        appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(userInfo.profileName,
            style: TextStyle(
              fontSize: 40,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              child: Text("Profile"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
              onPressed: () {},
            ),
        ]
        ),
        ),
          body: UploadPage()
      )
  );
}