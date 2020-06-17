/*
  Author: Conner Delahanty

  This page allows the user to see different businesses in their area,
  and subscribe to receive downs in their area.

  This feature gives the use additional value in seeing
  in-person specials from businesses, and have an easy way to invite
  people from these activities. This also keeps Down pages busy so there is
  no "left-outedness" and frustration. This feature encourages all people
  to be event planners.


  Also gives a business the ability to inform users of specials, and serves
  as a monitization opportunity for ourselves.

  Notes:

  Presently this is located as an additional tab. This could also replace the
  Friend/Group Page, or can be another tab of the Friend/Group Page.

  In Firebase, we keep a copy of all Businesses in "sponsored".
  They may post downs / details in "sponsoreddowns"

 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/User.dart';


class BusinessPage extends StatefulWidget {
  FirebaseUser user;

  BusinessPage(this.user);

  @override
  _BusinessPageState createState() => _BusinessPageState(this.user);
}

class _BusinessPageState extends State<BusinessPage> {
  FirebaseUser user;
  DatabaseReference dbAllUsers;
  DatabaseReference dbAllFriends;
  List<String> _friendUids = [];

  _BusinessPageState(this.user);


  @override
  Widget build(BuildContext buildContext) {
    return new Container(color: Colors.transparent);
  }




  }
