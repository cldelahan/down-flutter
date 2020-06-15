import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './MyApp.dart';
import '../Models/User.dart';
import '../Pages/SettingsPage.dart';

AppBar header(context, {FirebaseUser user, bool isAppTitle, String strTitle, bool incProfile=false, disappearedBackButton=false}) {


    return AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: disappearedBackButton ? IconTheme(data: IconThemeData(color: Colors.white), child: CloseButton()) : null,
        title: Text(
          isAppTitle ? "Down" : strTitle,
          style: TextStyle(
            color: Colors.white,
            fontFamily: isAppTitle ? "Signatra" : "Signatra",
            fontSize: isAppTitle ? 45.0 : 45.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      actions: incProfile ? <Widget>[
        FlatButton(
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage(user)),
            );
          },
          child: Text("Profile"),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        ),
      ] : null,
    );
  }