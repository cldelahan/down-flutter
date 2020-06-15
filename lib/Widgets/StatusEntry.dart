/*
  Author: Conner Delahanty

  Creates a StatusEntry - an object in "Pages/DownEntryDetails" that displays
  a status and deals with taps / etc.


  Notes:
    For reasons why this class exists, see "Pages/DownEntryDetails"
    documentation. Unfortunately, as a side effect,
    we have to read in the Down and the User from DownEntryDetails.

    Approach is:
      Have DownEntryDetails send initial list of all statuses to StatusEntry.
      Then StatusEntry maintains and changes on changes.


 */

import 'package:flutter/material.dart';
import '../Models/Down.dart';
import '../Widgets/HeaderWidget.dart';
import '../Models/User.dart';
import 'package:down/Models/Status.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_image/firebase_image.dart';

class StatusEntry extends StatefulWidget {
  FirebaseUser user;
  Down down;

  StatusEntry(this.user, this.down);

  @override
  _StatusEntryState createState() =>
      _StatusEntryState(this.user, this.down);
}

class _StatusEntryState extends State<StatusEntry> {
  FirebaseUser user;
  Down down;
  DatabaseReference dbDown;
  DatabaseReference dbAllUsers;

  _StatusEntryState(this.user, this.down);

  @override
  Widget build(BuildContext context) {
    return null;
  }

}
