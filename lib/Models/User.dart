import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_image/firebase_image.dart';

// template class to model a user
// allows for better importing into Firebase
class User {
  String id;
  String profileName = "";
  String username;
  String url;
  String email;
  String token;
  String phoneNumber;
  bool addedByPhone = false;
  bool invite = false;
  bool isDown = false;
  ImageProvider profileImage = null;

  User({
    this.id,
    this.profileName,
    // TODO: Do we want to distinguish between these two?
    this.username,
    this.url,
    this.email,
    this.token,
    this.addedByPhone,
  }) {
    id = "";
    profileName = "";
    username = "";
    url = "";
    email = "";
    token = "";
    phoneNumber = "";
    invite = false;
    isDown = false;
    profileImage = null;
    addedByPhone = false;

  }

  void cleanAndAddPhoneNumber(String number) {
    number = number.replaceAll("(", "");
    number = number.replaceAll(")", "");
    number = number.replaceAll(" ", "");
    number = number.replaceAll("-", "");
    // add country code
    // (default to US if not specified)
    if (!number.startsWith("+")) {
      number = "+1" + number;
    }
    // they likely forgot the + (for US numbers)
    if (number.length == 11 && number.startsWith("1")) {
      number = "+" + number;
    }
    // assert number is true length
    if (number.length != 12) {
      print("Non-standard phone number");
      print(number);
      this.phoneNumber = "";
    }
    this.phoneNumber = number;
  }


  /*
    Here we load the image depending on what type of user we have and how
    their image is stored. We then wrap the image in a decoration image (
    a more general representation) so we can return it
   */
  ImageProvider getImageOfUser() {

    if (profileImage == null) {
      if (this.addedByPhone) {
        profileImage = AssetImage('assets/images/phoneIcon.png');
      }
      else if (this.url.startsWith("gs")) {
        profileImage = FirebaseImage(this.url);
      } else {
        profileImage = NetworkImage(this.url);
      }
    }
    return profileImage;
  }

  /*
    Presently - in the case it is user addedByPhone, we must know
    which user we are talking about so we can retrieve his / her alias
   */
  static User populateFromDataSnapshot(DataSnapshot ds, FirebaseUser user) {
    Map entry = ds.value;

    User temp = new User();

    temp.isDown = false;

    // fill out standard fields of the user
    try {
      temp.id = ds.key;
      temp.email = entry["email"];
    } on Exception catch(_) {
      return null;
    }

    // they were added by phone
    if (entry['addedByPhone'] != null && entry['addedByPhone'] == true) {
      temp.addedByPhone = true;
      // in this case, their name takes a different structure
      temp.profileName = entry['aliases'][user.uid];
    }


    // they were added by down
    else {
      temp.profileName = entry['profileName'];
      temp.url = entry['url'];
      temp.email = entry['email'];
      temp.addedByPhone = false;
    }

    // TODO: should we load the image here or save for when we display?

    return temp;
  }

  static User populateFromMap(Map m, String uid) {
    if (m == null || uid == null) {
      return null;
    }
    return User(
      id: uid,
      profileName: m['profileName'],
      url: m['url'],
      email: m['email']
    );
  }

  String toString() {
    return this.profileName;
  }
}