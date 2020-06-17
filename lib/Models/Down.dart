/*
  Author: Conner Delahanty

  This contains code for a Down object. Most notably is a populateDown
  function below that takes a raw Down object, and gets required data
  from database to create down.

  Notes:
    For future reference, DateTime strings look like:
    19700101T071324, meaning: 01-01-1970, 7:13:24am

 */

import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/RecommendedActivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:down/Models/Status.dart';
import 'package:down/Models/User.dart';

// template class to model a user
// allows for better importing into Firebase
class Down {
  // firebase vars
  final dbDowns = FirebaseDatabase.instance.reference().child('downs');

  // raw values from database
  String id;
  String title;
  List<String> invitedIDs = [];
  List<bool> invitedUserIsDown = [];
  DateTime time;
  DateTime timeCreated;
  String address;
  String advertId;

  // derived values from database
  String creatorID;
  int nDown;
  int nInvited;
  bool isDown;

  User creator = new User();

  List<User> invitedUsers = [];

  //List<DownStatus> downStatuses;
  //List<String> invitedNames;zd
  // for getting additional data from database

  bool isBuildOffRecommendedActivity = false;
  RecommendedActivity recommendedActivity;

  Down({
    this.id,
    this.title,
    this.creatorID,
    this.nDown,
    this.invitedIDs,
    this.time,
    this.timeCreated,
    this.address,
    this.advertId,
    this.invitedUserIsDown,
  }) {
    if (this.invitedIDs == null) {
      this.nInvited = 0;
    } else {
      this.nInvited = this.invitedIDs.length;
    }

  }

  String getCleanTime() {
    String minute = this.time.minute.toString();
    String hour = (this.time.hour % 12) == 0 ? "12" : (this.time.hour % 12).toString();
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

  String getGoingSummary() {
    int nNotSeen = nInvited - 0; // normally  = nInvited - nSeen
    //TODO: Do we want to implement a seen Method? For now hardcoded at 0
    return nDown.toString() +
        " Down | " +
        // nNotSeen.toString() +
        // " Haven't Seen ~ " +
        nInvited.toString() +
        " Invited";
  }

  void setInvitedUsers(List<User> u) {
    this.invitedUsers = u;
  }

  ///
  /// populateDown takes a database reference at the level of the down and
  /// returns a Down object.
  /// Is it inefficient to recreate an array of downs anytime a down changes?
  /// Likely yes - but was the underlying component of Down 1.0
  ///
  static Down populateDown(DataSnapshot ds) {
    Map entry = ds.value;
    Down temp;
    print("Printing entry toString(): " + entry.toString());
    try {
      Map invitedToIsDown = Map<String, bool>.from(entry['invited']);
      List<String> invitedIDsTemp = invitedToIsDown.keys.toList();
      List<bool> invitedDownStatuses = invitedToIsDown.values.toList();
      int nDownTemp = 0;
      for (int i = 0; i < invitedDownStatuses.length; i++) {
        if (invitedDownStatuses[i]) {
          nDownTemp += 1;
        }
      }
      temp = Down(
        id: ds.key,
        creatorID: entry['creator'],
        nDown: nDownTemp,
        invitedIDs: invitedIDsTemp,
        time: DateTime.parse(entry['time']),
        timeCreated: DateTime.parse(entry['timeCreated']),
        title: entry['title'],
        invitedUserIsDown: invitedDownStatuses,
        address: entry['address'],
//advertId: entry['advertID'],
      );
      return temp;
    } on Exception catch (_) {
      return null;
    }
  }
}
