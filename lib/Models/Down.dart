/*
  Author: Conner Delahanty

  This contains code for a Down object. Most notably is a populateDown
  function below that takes a raw Down object, and gets required data
  from database to create down.

  Notes:
    For future reference, DateTime strings look like:
    19700101T071324, meaning: 01-01-1970, 7:13:24am

    06/22/20: Updated format so this class can carry more work when
    loading Downs.

 */

import 'package:firebase_database/firebase_database.dart';
import 'package:down/Models/RecommendedActivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:down/Models/Status.dart';
import 'package:down/Models/User.dart';

class Down implements Comparable<Down> {
  String id;
  String title;
  String creatorID;
  List<String> invitedUserIDs;
  List<bool> invitedUserIsDown = [];
  DateTime time;
  DateTime timeCreated;
  String address;
  Map<String, Status> statusesMap = {};
  Map<String, bool> isDownMap = {};

  // derived values from database
  User creator;
  Map<String, User> userMap = {};

  static Duration TIMETOOBSELETE = new Duration(hours: 12);

  // bool isBuildOffRecommendedActivity = false;
  // RecommendedActivity recommendedActivity;

  Down({
    this.id = "",
    this.title = "",
    this.creatorID = "",

    // ignore _invitedUserIDs for now
    // ignore time for now
    // ignore timeCreated for now
    this.address = "",
  });

  int compareTo(Down other) {
    if (this.time.isAtSameMomentAs(other.time)) {
      return 0;
    }
    // return -1 if this comes earlier than b
    if (this.time.isBefore(DateTime.now()) ==
        other.time.isBefore(DateTime.now())) {
      return this.time.isBefore(other.time) ? -1 : 1;
    } else {
      return this.time.isBefore(DateTime.now()) ? 1 : -1;
    }
  }

  bool equals(Down other) {
    return this.id == other.id;
  }

  void setTime(DateTime time) {
    this.time = time;
  }

  void setTimeCreated(DateTime timeCreated) {
    this.timeCreated = timeCreated;
  }

  void setInvitedUserIDs(List<String> invitedUserIDs) {
    this.invitedUserIDs = invitedUserIDs;
  }

  void setInvitedUserIsDown(List<bool> invitedUserIsDown) {
    this.invitedUserIsDown = invitedUserIsDown;
  }

  void setStatusesMap(Map<String, Status> statusesMap) {
    this.statusesMap = statusesMap;
  }

  Future<void> setAttribute(String attribute, var newValue) async {
    /*
      Set attribute performs a very nuanced role.
      Its work could be more easily accomplished with
      a Map as a Downs underlying data structure (TODO),
      but in our OOP approach, setAttribute takes the following
      form.
     */
    // only have implimented certain parameters
    if (attribute == "time") {
      this.setTime(DateTime.parse(newValue));
    } else if (attribute == "timeCreated") {
      this.setTimeCreated(DateTime.parse(newValue));
    } else if (attribute == "invited") {
      // if new people are invited or down statuses change
      // TODO: this operation could be less expensive
      print("Changing invited status");
      Map invitedMap = Map<String, bool>.from(newValue);
      List<String> invitedIDs = invitedMap.keys.toList();
      List<bool> invitedUserIsDown = invitedMap.values.toList();
      this.setInvitedUserIDs(invitedIDs == null ? [] : invitedIDs);
      this.setInvitedUserIsDown(
          invitedUserIsDown == null ? [] : invitedUserIsDown);
      this.isDownMap = invitedMap;
      await this.populateUsers();
    } else if (attribute == "status") {
      // there has been a change to one or many of the statuses
      // TODO: this operation could be less expensive
      List<String> statusCreators = List<String>.from(newValue.keys);
      Map<String, Status> uidToStatus = {};
      for (String uid in statusCreators) {
        Status tempStatus = Status.populateFromMap(newValue[uid]);
        tempStatus.poster = this.userMap[uid];
        uidToStatus[uid] = tempStatus;
      }
      this.setStatusesMap(uidToStatus);
    }
    return;
  }

  Future<void> populateUsers() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DatabaseReference allUsers =
        FirebaseDatabase.instance.reference().child("users");
    DataSnapshot creatorDS = await allUsers.child(creatorID).once();
    this.creator = User.populateFromDataSnapshot(creatorDS);

    DataSnapshot userDS;
    for (String id in this.invitedUserIDs) {
      userDS = await allUsers.child(id).once();
      User invited = User.populateFromDataSnapshotAndPhone(userDS, user);
      this.userMap[id] = invited;
    }
  }

  Future<void> safeDelete() async {
    DatabaseReference allUsers =
        FirebaseDatabase.instance.reference().child("users");
    for (String i in this.invitedUserIDs) {
      print(i);
      await allUsers.child(i).child("downs").child(this.id).remove();
    }
    await FirebaseDatabase.instance.reference().child("down").child(this.id).remove();
  }

  bool isUserDown(String userUID) {
    return this.isDownMap[userUID];
  }

  bool shouldDisplayDown() {
    return !this.time.add(TIMETOOBSELETE).isBefore(DateTime.now());
  }

  int getNumberInvited() {
    return this.invitedUserIDs.length;
  }

  User getUserObject(int index) {
    return userMap[invitedUserIDs[index]];
  }

  int getNumberDown() {
    int nDown = 0;
    for (bool isDown in this.invitedUserIsDown) {
      if (isDown) {
        nDown++;
      }
    }
    return nDown;
  }

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

  String getGoingSummary() {
    /*int nNotSeen = nInvited - 0; // normally  = nInvited - nSeen
    //TODO: Do we want to implement a seen Method? For now hardcoded at 0
    return nDown.toString() +
        " Down | " +
        // nNotSeen.toString() +
        // " Haven't Seen ~ " +
        nInvited.toString() +
        " Invited"; */
    return "getGoingSummary() not yet implimented";
  }

  static Future<Down> populateDown(DataSnapshot ds) async {
    Map entry = ds.value;
    Map invitedMap = Map<String, bool>.from(entry["invited"]);
    List<String> invitedIDs = invitedMap.keys.toList();
    List<bool> invitedUserIsDown = invitedMap.values.toList();

    Down temp = Down(
      id: ds.key,
      title: entry["title"],
      creatorID: entry["creator"],
    );

    temp.isDownMap = invitedMap;

    temp.setInvitedUserIDs(invitedIDs == null ? [] : invitedIDs);
    temp.setInvitedUserIsDown(
        invitedUserIsDown == null ? [] : invitedUserIsDown);
    temp.setTime(DateTime.parse(entry["time"]));
    temp.setTimeCreated(DateTime.parse(entry["timeCreated"]));

    await temp.populateUsers();

    if (entry["status"] == null) {
      return temp;
    }
    List<String> statusCreators = List<String>.from(entry["status"].keys);
    Map<String, Status> uidToStatus = {};
    for (String uid in statusCreators) {
      Status tempStatus = Status.populateFromMap(entry["status"][uid]);
      tempStatus.poster = temp.userMap[uid];
      uidToStatus[uid] = tempStatus;
    }
    temp.setStatusesMap(uidToStatus);

    return temp;
  }
}
