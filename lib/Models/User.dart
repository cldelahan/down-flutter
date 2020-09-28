import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_image/firebase_image.dart';


class User {
  String id;
  String profileName;
  String url;
  String email;
  String token;
  String phoneNumber;

  // other interesting values

  bool addedByPhone;
  /*
  bool addedByPhone = false;
  bool invite = false;
  bool isDown = false;*/
  ImageProvider profileImage = null;
  bool invite = false;

  User({
    this.id = "",
    this.profileName = "",
    this.url = "",
    this.email= "",
    this.token = "",
    this.phoneNumber = "",
    this.addedByPhone = false
  });

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

  String getInitials() {
    String temp = this.profileName.trim();
    int indexOfSpace = temp.indexOf(" ");
    String outputString = temp.substring(0, 1);
    if (indexOfSpace < 0) {
      return outputString;
    }
    outputString += temp.substring(indexOfSpace + 1, indexOfSpace + 2);
    print(outputString);
    return outputString;
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


  static User populateFromDataSnapshot(DataSnapshot ds) {
    Map entry = ds.value;
    User temp = User(
      id: ds.key,
      profileName: entry["profileName"],
      url: entry["url"],
      email: entry["email"],
      addedByPhone: false
    );

    return temp;
  }
  /*
    Presently - in the case it is user addedByPhone, we must know
    which user we are talking about so we can retrieve his / her alias
   */
  static User populateFromDataSnapshotAndPhone(DataSnapshot ds, FirebaseUser user) {
    Map entry = ds.value;

    User temp = new User();


    // fill out standard fields of the user
    try {
      temp.id = ds.key;
      temp.phoneNumber = entry["phone"];
    } on Exception catch(_) {
      return null;
    }

    // they were added by phone
    if (entry['addedByPhone'] != null && entry['addedByPhone'] == true) {
      temp.addedByPhone = true;
      // in this case, their name takes a different structure
      temp.profileName = entry['aliases'][user.uid];
      temp.url = "";
    }


    // they were added by down
    else {
      temp.profileName = entry['profileName'];
      temp.url = entry['url'];
      temp.email = entry['email'];
      temp.addedByPhone = false;

      /*
    // they were added by phone
    if (entry['addedByPhone'] != null && entry['addedByPhone'] == true) {
      temp.addedByPhone = true;
      // in this case, their name takes a different structure
      temp.profileName = entry['aliases'][user.uid];
    }*/

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