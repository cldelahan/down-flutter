/*
  Author: Conner Delahanty

  This contains code for an Organization. An organization is any business,
  club, etc. that would need the ability to post on the "Things to do" page.

  A user is either subscribed or not subscribed to an organization.

  This contains data about the organization, and a few '4th wall'
  variables that lets us determine if our user is subscribed or not.

  Notes:
    Address of the organization is kept with each down - not with the
    organization.

 */

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:down/Models/RecommendedActivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:down/Models/Status.dart';
import 'package:down/Models/User.dart';

class Organization {

  String id;
  String name;
  String url;
  String website;
  String about;

  ImageProvider profileImage = null;

  ImageProvider getImageOfOrganization() {
    if (profileImage == null) {
      if (this.url.startsWith("gs")) {
        profileImage = FirebaseImage(this.url);
      } else {
        profileImage = NetworkImage(this.url);
      }
    }
    return profileImage;
  }

  bool equals(Organization other) {
    return this.id == other.id;
  }

  static Organization populateFromDataSnapshot(DataSnapshot ds) {
    Map entry = ds.value;
    Organization temp = new Organization();
    temp.id = ds.key;
    temp.name = entry["name"];
    temp.url = entry["url"];
    temp.website = entry["website"];
    temp.about = entry["about"];

    return temp;
  }

}