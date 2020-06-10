/*
  Author: Conner Delahanty

  This page models a recommended activity, be it sponsored or non-sponsored.
  Ideally, we would have a general activity class, with two sub-classes for
  sponsored or non-sponsored. This has yet to be implemented, but more
  generally we can put both in here now.

  Notes:

 */

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RecommendedActivity {
  String id;
  String name;
  String address;
  DateTime startTime;
  DateTime endTime;
  bool running;
  String sponsorID;
  String mainGraphicUrl;
  String secondaryGraphicUrl;
  String smallGraphicUrl;

  // should likely not be stored here, for general (non-sponsored) activity
  bool usingIcon = false;
  IconData icon;



  RecommendedActivity({this.id, this.name, this.address, this.running, this.smallGraphicUrl, this.icon, this.usingIcon});

  static RecommendedActivity populateFromSnapshot(DataSnapshot ds) {
    Map entry = ds.value;
    RecommendedActivity temp = new RecommendedActivity(
        id: ds.key,
        name: entry["name"],
        address: entry["address"],
        smallGraphicUrl: entry["url"],
        running: entry["running"],
        usingIcon: false
    );
    return temp;
  }
}