import 'package:flutter/material.dart';
import './MyApp.dart';
import '../Models/User.dart';
import '../Pages/SettingsPage.dart';

AppBar header(context, {bool isAppTitle, String strTitle, bool incProfile=false, disappearedBackButton=false}) {
  // would not have a user here - would source data from some percistant state
  // put temporarily for testing
  User test = User(id: "acasf", profileName: "cldelahan", email: "cldelahan@gmail.com");

  if (!incProfile) {
    return AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        automaticallyImplyLeading: disappearedBackButton ? false : true,
        title: Text(
          isAppTitle ? "Down" : strTitle,
          style: TextStyle(
            color: Colors.white,
            fontFamily: isAppTitle ? "Signatra" : "",
            fontSize: isAppTitle ? 45.0 : 22.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .primaryColor
    );
  } else {
    return AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        automaticallyImplyLeading: disappearedBackButton ? false : true,
        title: Text(
          isAppTitle ? "Down" : strTitle,
          style: TextStyle(
            color: Colors.white,
            fontFamily: isAppTitle ? "Signatra" : "",
            fontSize: isAppTitle ? 45.0 : 22.0,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .primaryColor,
    actions: <Widget>[
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
    ],
  );
}
}