import 'package:firebase_database/firebase_database.dart';

// template class to model a user
// allows for better importing into Firebase
class Down {
  final String id;
  final String creatorID;
  String creator;
  final List<String> invited;
  final int nDown;
  final int nInvited;
  final DateTime time;
  final DateTime timeCreated;
  final String title;
  final String address;
  final String advertId;
  int nSeen = 0;
  // isDown shouldn't normally be stored here
  bool isDown = false;

  Down({
    this.id,
    this.creatorID,
    this.creator,
    this.invited,
    this.nDown,
    this.nInvited,
    this.time,
    this.timeCreated,
    this.title,
    this.address,
    this.advertId,
    this.isDown,
    this.nSeen = 0
  });

  String getCleanTime() {
    String minute = this.time.minute.toString();
    String hour = (this.time.hour % 12 + 1).toString();
    // Would need changed if we abandoned the 24-hour approach
    String todayOrTom = this.time.day == DateTime.now().day ? "Today" : "Tomorrow";
    String amPm = this.time.hour > 11 ? "pm" : "am";

    if (minute.length == 1) {
      minute = "0" + minute;
    }
    if (hour.length == 1) {
      hour = "0" + hour;
    }

    return todayOrTom + "  " + hour+ ":" + minute + " " + amPm;
  }

  String getGoingSummary() {
    int nNotSeen = nInvited - 0; // normally  = nInvited - nSeen
    //TODO: Do we want to implement a seen Method? For now hardcoded at 0
    return nDown.toString() + " Down ~ " + nNotSeen.toString() + " Haven't Seen ~ " +
      nInvited.toString() + " Invited";
  }



  ///
  /// populateDown takes a database reference at the level of the down and
  /// returns a Down object.
  /// Is it inefficient to recreate an array of downs anytime a down changes?
  /// Likely yes - but was the underlying component of Down 1.0
  ///
  static Down populateDown(DataSnapshot ds) {
    Map entry = ds.value;
    Map invited = Map<String,int>.from(entry['invited']);
    print(invited.keys.toList()[0]);
    return Down(
      id: ds.key,
      creatorID: entry['creator'],
      nInvited: entry['nInvited'],
      nDown: entry['nDown'],
      invited: invited.keys.toList(),
      // DateTime strings look like
      // 19700101T071324
      // for 01-01-1970, 7:13:24am
      time: DateTime.parse(entry['time']),
      timeCreated: DateTime.parse(entry['timeCreated']),
      title: entry['title'],
      address: entry['address'],
      advertId: entry['advertID'],
      isDown: false
    );
  }

}