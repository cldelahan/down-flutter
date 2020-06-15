/*
  Author: Conner Delahanty

  This code creates a SettingEntry object.

  Notes:

  6/12/20

  MARKED OBSOLETE
  After discovering ListTile, and after implementing storing to database,
  this file is obsolete and its implementation can be found in the settings page.


 */

import 'package:flutter/material.dart';

Widget settingEntry(context, String title, IconData icon) {
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

  return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
      child: Container(
          color: Colors.white,
          child: GestureDetector(
              onTap: () {
                // TODO
                // add down status to firebase
                return showDialog(context: context, builder: (context) {
                  return s;
                });
              },
              child: Row(children: <Widget>[
                Icon(icon, size: 35),
                SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                      fontSize: 25,
                      fontFamily: "Lato",
                      color: Colors.black,
                    ))
              ]))));
}
