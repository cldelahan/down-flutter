/*
  Author: Conner Delahanty

  This contains code for a SponsoredDown - a lightweight version of a down.


  Notes:
    TODO: Look into using OOP to better organize SponsoredDown,
    TODO: ... RecommendedActivity, and Down

 */

import 'package:down/Models/Organization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/RecommendedActivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:down/Models/Status.dart';
import 'package:down/Models/User.dart';

// template class to model a down
// allows for better importing into Firebase
class SponsoredDown {
  // firebase vars
  // raw values from database
  String id;
  String title;
  String address;
  DateTime time;
  DateTime timeCreated;

  String organizationID;
  Organization organization;

  String getCleanTime() {
    String minute = this.time.minute.toString();
    String hour =
        (this.time.hour % 12) == 0 ? "12" : (this.time.hour % 12).toString();
    // Would need changed if we abandoned the 24-hour approach
    String todayOrTom =
        this.time.day == DateTime.now().day ? "Today" : "Tomorrow";
    String amPm = this.time.hour > 11 ? "pm" : "am";

    if (minute.length == 1) {
      minute = "0" + minute;
    }
    if (hour.length == 1) {
      hour = "0" + hour;
    }

    return todayOrTom + "  " + hour + ":" + minute + " " + amPm;
  }

  Future<void> populateOrganization() async {
    DataSnapshot orgData = await FirebaseDatabase.instance
        .reference()
        .child("sponsored/organizations/${this.organizationID}")
        .once();
    Organization creatorOrg = Organization.populateFromDataSnapshot(orgData);
    this.organization = creatorOrg;
  }

  static Future<SponsoredDown> populateDown(DataSnapshot ds) async {
    Map entry = ds.value;
    SponsoredDown temp = new SponsoredDown();

    print(entry);
    print(entry["title"]);
    print(entry["time"]);
    temp.id = ds.key;
    temp.title = entry["title"];
    temp.address = entry["address"];
    temp.time = DateTime.parse(entry["time"]);
    temp.timeCreated = DateTime.parse(entry["timeCreated"]);
    temp.organizationID = entry["organization"];

    await temp.populateOrganization();

    return temp;
  }
}
