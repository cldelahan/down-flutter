import 'package:flutter/material.dart';
import './MyApp.dart';
import '../Models/User.dart';
import '../Pages/SettingsPage.dart';

AppBar header(context, {bool isAppTitle, String strTitle, bool incProfile=false, disappearedBackButton=false}) {
  // would not have a user here - would source data from some persistent state
  // put temporarily for testing
  User test = User(id: "acasf", profileName: "Conner Delahanty", email: "cldelahan@gmail.com", url: "http://connerdelahanty.com/ConnerDelahanty.jpg");

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
              MaterialPageRoute(builder: (context) => settingsPage(context, test, true)),
            );
          },
          child: Text("Profile"),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        ),
      ] : null,
    );
  }